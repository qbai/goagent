//
//  GAService.h
//  GoAgentX
//
//  Created by Xu Jiwei on 12-4-24.
//  Copyright (c) 2012年 xujiwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GACommandRunner.h"
#import "Reachability.h"

@class GAService;

typedef void (^GAServiceStatusChangedHandler)(GAService *service);


@interface GAService : NSObject {
    NSMutableDictionary             *previousDeviceProxies;
    
    GACommandRunner                 *commandRunner;
    GAAutoscrollTextView            *outputTextView;
    GAServiceStatusChangedHandler   statusChangedHandler;
    
    BOOL                    manualStopped;
    BOOL                    stoppedForNetworkProblem;
}

+ (id)sharedService;

- (BOOL)hasConfigured;

- (BOOL)couldAutoStart;

- (BOOL)supportReconnectAfterDisconnected;

- (BOOL)autoDisconnectWhenNetworkIsUnreachable;

- (BOOL)canShowInSwitchMenu;

- (NSString *)configTemplate;

- (NSString *)configPath;

- (NSString *)configValueForKey:(NSString *)key;

- (void)writeConfigFile;

- (NSString *)serviceName;

- (NSString *)serviceTitle;

- (NSString *)serviceWorkDirectory;

- (NSString *)pathInApplicationSupportFolder:(NSString *)path;

- (int)proxyPort;

- (NSArray *)proxyTypes;

- (void)notifyStatusChanged;

- (void)setupWorkDirectory;

- (void)setupCommandRunner;

- (BOOL)isRunning;

- (BOOL)willAutoReconnect;

- (void)toggleSystemProxy:(BOOL)useProxy;

- (void)start;

- (void)stop;

@property (nonatomic, strong)   GAAutoscrollTextView        *outputTextView;
@property (nonatomic, copy)     GAServiceStatusChangedHandler   statusChangedHandler;
@property (nonatomic, assign)  BOOL                    manualStopped;

@end
