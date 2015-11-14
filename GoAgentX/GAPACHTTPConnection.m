//
//  GAPACHTTPConnection.m
//  GoAgentX
//
//  Created by Xu Jiwei on 12-4-26.
//  Copyright (c) 2012年 xujiwei.com. All rights reserved.
//

#import "GAPACHTTPConnection.h"

#import "GAAppDelegate.h"
#import "GAPACHTTPServer.h"
#import "HTTPDynamicFileResponse.h"
#import "NSData+Base64.h"
#import "HTTPFileResponse.h"
#import "HTTPMessage.h"

@implementation GAPACHTTPConnection

- (NSString *)customPACDomainList {
    NSData *domainListData = [[NSUserDefaults standardUserDefaults] dataForKey:@"GoAgentX:CustomPACDomainList"];
    NSString *customDomainListString = domainListData ? [(NSAttributedString *)[NSUnarchiver unarchiveObjectWithData:domainListData] string] : @"";
    customDomainListString = [customDomainListString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    customDomainListString = [customDomainListString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *customDomainList = [customDomainListString componentsSeparatedByString:@"\n"];
    
    NSMutableArray *ret = [NSMutableArray new];
    for (NSString *line in customDomainList) {
        if ([line length] > 0) {
            [ret addObject:line];
        }
    }
    
    if ([ret count] > 0) {
        return [NSString stringWithFormat:@"|| shExpMatch(host, \"%@\")", [ret componentsJoinedByString:@"\")\n\t|| shExpMatch(host, \""]];
    }
    
    return @"";
}


- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    BOOL useCustomePAC = [[NSUserDefaults standardUserDefaults] boolForKey:@"GoAgent:UseCustomPACAddress"];
    NSString *customPAC = [[NSUserDefaults standardUserDefaults] stringForKey:@"GoAgent:CustomPACAddress"];
    
    if (useCustomePAC && customPAC.length > 0) {
        NSString *filePath = [[NSURL URLWithString:customPAC] path];
        return [[HTTPFileResponse alloc] initWithFilePath:filePath forConnection:self];
    }
    
	NSString *filePath = [self filePathForURI:path];
	
	// Convert to relative path
	
	NSString *documentRoot = [config documentRoot];
	
	if (![filePath hasPrefix:documentRoot]) {
		// Uh oh.
		// HTTPConnection's filePathForURI was supposed to take care of this for us.
		return nil;
	}
	
	NSString *relativePath = [filePath substringFromIndex:[documentRoot length]];
    
	if ([relativePath isEqualToString:@"/proxy.pac"]) {
        NSString *pacTemplate = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pactemplate" ofType:@"pac"] encoding:NSUTF8StringEncoding error:NULL];
        pacTemplate = [[NSString alloc] initWithData:[NSData dataFromBase64String:pacTemplate] encoding:NSUTF8StringEncoding];

        GAAppDelegate* delegate = [NSApp delegate];
        NSArray *proxyTypes = [[delegate currentService] proxyTypes];
        int proxyPort = [[delegate currentService] proxyPort];
        
        NSString *host = [request headerField:@"Host"];
        if ([host rangeOfString:@":"].location != NSNotFound) {
            host = [host substringToIndex:[host rangeOfString:@":"].location];
        }
        host = [host stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (host.length == 0) {
            host = @"127.0.0.1";
        }
        
        NSString *proxyAddress = [NSString stringWithFormat:@" %@:%d; ", host, proxyPort];
        NSString *proxySetting = [[proxyTypes arrayByAddingObject:@"DIRECT"] componentsJoinedByString:proxyAddress];
        
        NSString *pacContent = [pacTemplate stringByReplacingOccurrencesOfString:@"PROXY 127.0.0.1:65536"
                                                                      withString:proxySetting];
        pacContent = [pacContent stringByReplacingOccurrencesOfString:@"${GoAgentX:CustomPACDomainList}"
                                                           withString:[self customPACDomainList]];
        
        NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithObject:pacContent forKey:@"PAC_CONTENT"];
		
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
                                                   forConnection:self
                                                       separator:@"%%"
                                           replacementDictionary:replacementDict];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

@end
