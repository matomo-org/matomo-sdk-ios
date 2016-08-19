//
//  PiwikAFNetworking2Dispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 02/09/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikAFNetworking2Dispatcher.h"
#import "AFNetworking.h"

@interface PiwikAFNetworking2Dispatcher ()

@property (nonatomic, readonly) NSString *piwikPath;

@end


@implementation PiwikAFNetworking2Dispatcher

- (instancetype)initWithPiwikURL:(NSURL*)piwikURL {
  
  // AF Networkning adds training / to the base URL automatically
  self = [super initWithBaseURL:piwikURL.baseURL];
  if (self) {
    // Since the path below starts with a / the base URL will be truncated
    _piwikPath = piwikURL.path;
  }
  return self;
}

- (void)sendSingleEventWithParameters:(NSDictionary*)parameters
                              success:(void (^)())successBlock
                              failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  self.requestSerializer = [AFHTTPRequestSerializer serializer];
  self.responseSerializer = [AFImageResponseSerializer serializer];
  
  if (self.userAgent) {
    [self.requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
  }
  
  [self GET:self.piwikPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    //NSLog(@"Successfully sent stats to Piwik server");
    successBlock();
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    //NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
    failureBlock([self shouldAbortdispatchForNetworkError:error]);
  }];
  
}

- (void)sendBulkEventWithParameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  self.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:kNilOptions];
  self.responseSerializer = [AFJSONResponseSerializer serializer];

  if (self.userAgent) {
    [self.requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
  }
  
  [self POST:self.piwikPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    //NSLog(@"Successfully sent stats to Piwik server");
    successBlock();
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    //NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
    failureBlock([self shouldAbortdispatchForNetworkError:error]);    
  }];
  
}

// Should the dispatch be aborted and pending events rescheduled
- (BOOL)shouldAbortdispatchForNetworkError:(NSError*)error {
  
  if (error.code == NSURLErrorBadURL ||
      error.code == NSURLErrorUnsupportedURL ||
      error.code == NSURLErrorCannotFindHost ||
      error.code == NSURLErrorCannotConnectToHost ||
      error.code == NSURLErrorDNSLookupFailed) {
    return YES;
  } else {
    return NO;
  }
  
}



@end
