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

@property (readonly) NSString *authenticationToken;
@property (readonly) NSString *siteId;

@property (readonly) NSString *cliendId;
@property (nonatomic) double sampleRate;

@property (nonatomic) NSString *appName;
@property (nonatomic) NSString *appVersion;


+ (instancetype)trackerWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken baseURL:(NSString*)baseURL;

- (BOOL)sendView:(NSString*)screen;
- (BOOL)sendEventWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label;

@end
