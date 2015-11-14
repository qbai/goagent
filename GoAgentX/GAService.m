//
//  GAService.m
//  GoAgentX
//
//  Created by Xu Jiwei on 12-4-24.
//  Copyright (c) 2012年 xujiwei.com. All rights reserved.
//

#define NOT_IMPL  @throw [[NSException alloc] initWithName:@"NotImplenmentException" reason:@"__PRETTY_FUNCTION__" userInfo:nil];

#import "GAService.h"

#import "GAConfigFieldManager.h"
#import "GAPACHTTPServer.h"

@interface GAService ()

- (NSString *)serviceWorkDirectory;

@end


@implementation GAService

@synthesize statusChangedHandler;
@synthesize outputTextView;
@synthesize manualStopped;

static NSMutableDictionary *sharedContainer = nil;
static Reachability *internetReachability = nil;

static AuthorizationRef authRef;
static AuthorizationFlags authFlags;

+ (void)initialize {
    if (self == [GAService class]) {
        sharedContainer = [NSMutableDictionary new];
        
        internetReachability = [Reachability reachabilityForInternetConnection];
        [internetReachability startNotifier];
                
        authFlags = kAuthorizationFlagDefaults
                    | kAuthorizationFlagExtendRights
                    | kAuthorizationFlagInteractionAllowed
                    | kAuthorizationFlagPreAuthorize;
        OSStatus authErr = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, authFlags, &authRef);
        if (authErr != noErr) {
            authRef = nil;
        }
    }
}


+ (id)sharedService {
    NSString *key = NSStringFromClass(self);
    
	@synchronized(self) {
		if ([sharedContainer objectForKey:key] == nil) {
            [sharedContainer setObject:[[self alloc] init] forKey:key];
		}
	}
    
	return [sharedContainer objectForKey:key];
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
        NSString *key = NSStringFromClass(self);
		if ([sharedContainer objectForKey:key] == nil) {
            [sharedContainer setObject:[super allocWithZone:zone] forKey:key];
            return [sharedContainer objectForKey:key];
		}
	}
    
	return nil;
}


- (id)copyWithZone:(NSZone *)zone {
	return self;
}


- (id)init {
    if (self = [super init]) {
        previousDeviceProxies = [NSMutableDictionary new];
        manualStopped = YES;
        stoppedForNetworkProblem = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChanged:) name:kReachabilityChangedNotification object:nil];
    }
    
    return self;
}


- (BOOL)couldAutoStart {
    return YES;
}


- (BOOL)hasConfigured {
    NOT_IMPL
}


- (NSString *)configTemplate {
    NOT_IMPL
}


- (NSString *)configPath {
    NOT_IMPL
}


- (NSString *)serviceTitle {
    NOT_IMPL
}


- (BOOL)supportReconnectAfterDisconnected {
    return NO;
}


- (BOOL)autoDisconnectWhenNetworkIsUnreachable {
    return NO;
}


- (BOOL)canShowInSwitchMenu {
    return YES;
}


- (int)proxyPort {
    return 0;
}

- (bool)listenOnRemote {
    return NO;
}


- (NSArray *)proxyTypes {
    return nil;
}


- (void)notifyStatusChanged {
    // 如果有设置自动切换系统代理设置，切换系统代理设置
    if ([self proxyTypes].count > 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:DontAutoToggleSystemProxySettings"]) {
        [self toggleSystemProxy:[self isRunning]];
    }

    if (statusChangedHandler) {
        statusChangedHandler(self);
    }
    
    if (![self isRunning]) {
        [self.outputTextView appendString:[NSString stringWithFormat:@"%@ 已停止\n\n", [self serviceTitle]]];
    }
    
    // 自动重连
    if (![self isRunning] && [self supportReconnectAfterDisconnected] && !self.manualStopped) {
        [self.outputTextView appendString:[NSString stringWithFormat:@"%@ 5 秒后将尝试重新连接...\n\n", [self serviceTitle]]];
        [self performSelector:@selector(start) withObject:nil afterDelay:5.0];
    }
}


- (void)setupCommandRunner {
    if (commandRunner == nil) {
        commandRunner = [GACommandRunner new];
    }
    
    commandRunner.outputTextView = self.outputTextView;
    commandRunner.workDirectory = [self serviceWorkDirectory];
    
    __block id _self = self;
    commandRunner.terminationHandler = ^(NSTask *task) {
        [_self notifyStatusChanged];
    };
}


- (BOOL)isRunning {
    BOOL running = [commandRunner isTaskRunning];
    return running;
}


- (BOOL)willAutoReconnect {
    BOOL autoReconnect = (![self isRunning] && [self supportReconnectAfterDisconnected] && !self.manualStopped);
    BOOL networkProblem = stoppedForNetworkProblem;
    return autoReconnect || networkProblem;
}


- (void)start {
    stoppedForNetworkProblem = NO;
    
    // 取消之前的可能的自动重连
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    
    if (![self hasConfigured]) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"请进行服务配置", nil)
                                         defaultButton:nil
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        [alert runModal];
        return;
    }
    
    if (![commandRunner isTaskRunning]) {
        [self.outputTextView appendString:[NSString stringWithFormat:@"%@ %@...\n",
                                           [self serviceTitle],
                                           NSLocalizedString(@"正在启动", nil)]];
        
        // 关闭可能的上次运行的进程
        NSInteger lastRunPID = [[NSUserDefaults standardUserDefaults] integerForKey:@"GoAgent:LastRunPID"];
        if (lastRunPID > 0 && kill((int)lastRunPID, 0) == 0) {
            kill((int)lastRunPID, 9);
        }
        
        self.manualStopped = NO;
        
        [self setupWorkDirectory];
        [self setupCommandRunner];
        [commandRunner run];
        
        [self.outputTextView appendString:NSLocalizedString(@"启动完成", nil)];
        [self.outputTextView appendString:@"\n"];
        [[NSUserDefaults standardUserDefaults] setInteger:[commandRunner processId] forKey:@"GoAgent:LastRunPID"];
        
        [self notifyStatusChanged];
    }
}


- (void)stop {
    self.manualStopped = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ([commandRunner isTaskRunning]) {
        [commandRunner terminateTask];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GoAgent:LastRunPID"];
    }
}


- (NSString *)serviceName {
    NOT_IMPL
}


- (NSString *)configValueForKey:(NSString *)key {
    return [[GAConfigFieldManager sharedManager] configValueForKey:key ofService:[self serviceName]];
}


- (NSString *)pathInApplicationSupportFolder:(NSString *)path {
    NSString *folder = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
                         stringByAppendingPathComponent:@"Application Support"]
                        stringByAppendingPathComponent:@"GoAgentX"];
    return [folder stringByAppendingPathComponent:path];
}


- (NSString *)serviceWorkDirectory {
    return [self pathInApplicationSupportFolder:[self serviceName]];
}


- (NSDictionary *)defaultsSettings {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoAgentXDefaultsSettings" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}


- (NSDictionary *)defaultsValueMap {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoAgentXDefaultsValueMap" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}


- (void)writeConfigFile {
    if ([self configPath] == nil) {
        return;
    }
    
    NSDictionary *defaults = [self defaultsSettings];
    NSDictionary *valuesMap = [self defaultsValueMap];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *configContent = [self configTemplate];
    
    for (NSString *key in [defaults allKeys]) {
        NSString *value = [userDefaults stringForKey:key] ?: @"";
        NSArray *valueMap = [valuesMap objectForKey:key];
        
        if (valueMap != nil) {
            value = [valueMap objectAtIndex:[value intValue]];
        }
        
        configContent = [configContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key]
                                                                 withString:value ?: @""];
    }
    
    NSString *path = [[self serviceWorkDirectory] stringByAppendingPathComponent:[self configPath]];
    [configContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}


- (void)setupWorkDirectory {
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:[self serviceName] ofType:@""];
    NSString *destPath = [self pathInApplicationSupportFolder:[self serviceName]];
    
    [[NSFileManager defaultManager] removeItemAtPath:destPath error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:[destPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:destPath error:NULL];
    
    [self writeConfigFile];
}


#pragma mark -
#pragma mark 代理设置

- (NSString *)proxiesPathOfDevice:(NSString *)devId {
    NSString *path = [NSString stringWithFormat:@"/%@/%@/%@", kSCPrefNetworkServices, devId, kSCEntNetProxies];
    return path;
}


//! 修改代理设置的字典
- (void)modifyPrefProxiesDictionary:(NSMutableDictionary *)proxies withProxyEnabled:(BOOL)enabled {
    // 先禁用所有代理，防止之前已经设置过一些会导致冲突
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPSEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
    
    if (enabled) {
        NSInteger proxyPort = [self proxyPort];
        NSArray *proxyTypes = [self proxyTypes];
        
        BOOL usePAC = [[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:AutoToggleSystemProxyWithPAC"];
        BOOL useCustomePAC = [[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:UseCustomPACAddress"];
        NSString *customPAC = [[NSUserDefaults standardUserDefaults] stringForKey:@"GoAgent:CustomPACAddress"];
        NSString *pacFile = (useCustomePAC && ![customPAC hasPrefix:@"file://"]) ? customPAC : [[GAPACHTTPServer sharedServer] pacAddressForProxy];
        
        if (usePAC) {
            // 使用 PAC
            [proxies setObject:pacFile forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
            [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
            
        } else if ([proxyTypes indexOfObject:@"PROXY"] != NSNotFound) {
            // 使用 HTTP 代理
            [proxies setObject:[NSNumber numberWithInteger:proxyPort] forKey:(NSString *)kCFNetworkProxiesHTTPPort];
            [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPProxy];
            [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesHTTPEnable];
            [proxies setObject:[NSNumber numberWithInteger:proxyPort] forKey:(NSString *)kCFNetworkProxiesHTTPSPort];
            [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPSProxy];
            [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesHTTPSEnable];
            
        } else if ([proxyTypes indexOfObject:@"SOCKS"] != NSNotFound ||
                   [proxyTypes indexOfObject:@"SOCKS5"] != NSNotFound) {
            // 使用 SOCKS 代理
            [proxies setObject:[NSNumber numberWithInteger:proxyPort] forKey:(NSString *)kCFNetworkProxiesSOCKSPort];
            [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesSOCKSProxy];
            [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
        }
    }
}


- (void)toggleSystemProxy:(BOOL)useProxy {
    if (authRef == NULL) {
      NSLog(@"No authorization has been granted to modify network configuration");
      return;
    }

    BOOL usePAC = [[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:AutoToggleSystemProxyWithPAC"];
    NSLog(@"Toggle system proxy %@ with PAC %@", useProxy ? @"YES" : @"NO", usePAC ? @"YES" : @"NO");
    
    SCPreferencesRef prefRef = SCPreferencesCreateWithAuthorization(nil, CFSTR("GoAgentX"), nil, authRef);

    NSDictionary *sets = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);
    
    // 遍历系统中的网络设备列表，设置 AirPort 和 Ethernet 的代理
    if (previousDeviceProxies.count == 0) {
        for (NSString *key in [sets allKeys]) {
            NSMutableDictionary *dict = [sets objectForKey:key];
            NSString *hardware = [dict valueForKeyPath:@"Interface.Hardware"];
            if ([hardware isEqualToString:@"AirPort"] || [hardware isEqualToString:@"Ethernet"]) {
                NSDictionary *proxies = [dict objectForKey:(NSString *)kSCEntNetProxies];
                if (proxies != nil) {
                    [previousDeviceProxies setObject:[proxies mutableCopy] forKey:key];
                }
            }
        }
    }
    
    if (useProxy) {        
        // 如果已经获取了旧的代理设置就直接用之前获取的，防止第二次获取到设置过的代理
        for (NSString *deviceId in previousDeviceProxies) {
            CFDictionaryRef proxies = SCPreferencesPathGetValue(prefRef, (__bridge CFStringRef)[self proxiesPathOfDevice:deviceId]);
            [self modifyPrefProxiesDictionary:(__bridge NSMutableDictionary *)proxies withProxyEnabled:YES];
            SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)[self proxiesPathOfDevice:deviceId], proxies);
        }
        
    } else {
        for (NSString *deviceId in previousDeviceProxies) {
            // 防止之前获取的代理配置还是启用了 SOCKS 代理或者 PAC 的，直接将两种代理方式禁用
            NSMutableDictionary *dict = [previousDeviceProxies objectForKey:deviceId];
            [self modifyPrefProxiesDictionary:dict withProxyEnabled:NO];
            SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)[self proxiesPathOfDevice:deviceId], (__bridge CFDictionaryRef)dict);
        }
        
        [previousDeviceProxies removeAllObjects];
    }
    
    SCPreferencesCommitChanges(prefRef);
    SCPreferencesApplyChanges(prefRef);
    SCPreferencesSynchronize(prefRef);
}


#pragma mark - 网络状态变化

- (void)networkStateChanged:(NSNotification *)note {
    if ([self autoDisconnectWhenNetworkIsUnreachable]) {
        if ([internetReachability currentReachabilityStatus] == NotReachable) {
            if ([self isRunning]) {
                stoppedForNetworkProblem = YES;
                [self stop];
            }
            
        } else {
            if (stoppedForNetworkProblem) {
                [self start];
                stoppedForNetworkProblem = NO;
            }
        }
    }
}


@end
