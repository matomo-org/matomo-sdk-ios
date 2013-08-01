//
//  PiwikTracker.h
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"


@interface PiwikTracker : AFHTTPClient

@property (nonatomic, readonly) NSString *siteId;
@property (nonatomic, readonly) NSString *authenticationToken;

@property (nonatomic, readonly) NSString *cliendId;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appVersion;

@property(nonatomic) BOOL debug;
@property(nonatomic) BOOL optOut;
@property (nonatomic) double sampleRate;

@property (nonatomic) BOOL sessionStart;
@property (nonatomic) BOOL sessionTimeout;

@property(nonatomic) NSTimeInterval dispatchInterval;


+ (instancetype)sharedInstanceWithBaseURL:(NSURL*)baseURL siteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken;
+ (instancetype)sharedInstance;

- (BOOL)sendView:(NSString*)screen;
- (BOOL)sendViews:(NSString*)screen, ...;

- (BOOL)sendEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label;

- (BOOL)dispatch;

- (void)deleteQueuedEvents;

@end
