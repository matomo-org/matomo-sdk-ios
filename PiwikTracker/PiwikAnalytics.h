//
//  PiwikAnalytics.h
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import <Foundation/Foundation.h>

@class PiwikTracker;

@interface PiwikAnalytics : NSObject

@property(nonatomic, weak) PiwikTracker *defaultTracker;
@property(nonatomic) BOOL debug;
@property(nonatomic) BOOL optOut;
@property(nonatomic) NSTimeInterval dispatchInterval;

+ (instancetype)sharedInstance;

- (PiwikTracker*)trackerWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken
                           baseURL:(NSString*)baseURL;
- (void)dispatch;

@end
