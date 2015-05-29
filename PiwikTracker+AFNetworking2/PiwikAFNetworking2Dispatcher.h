//
//  PiwikAFNetworking2Dispatcher.h
//  PiwikTracker
//
//  Created by Mattias Levin on 02/09/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikDispatcher.h"
#import "AFHTTPSessionManager.h"

@interface PiwikAFNetworking2Dispatcher : AFHTTPSessionManager  <PiwikDispatcher>

@property (nonatomic, strong) NSString *userAgent;

- (instancetype)initWithPiwikURL:(NSURL*)piwikURL;

@end
