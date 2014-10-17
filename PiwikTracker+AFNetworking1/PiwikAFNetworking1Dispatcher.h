//
//  PiwikAFNetworkingDispatcher.h
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikDispatcher.h"
#import "AFHTTPClient.h"

@interface PiwikAFNetworking1Dispatcher : AFHTTPClient <PiwikDispatcher>

- (instancetype)initWithPiwikURL:(NSURL*)piwikURL;

@end
