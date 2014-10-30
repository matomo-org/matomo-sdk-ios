//
//  PiwikAFNetworkingDispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikAFNetworking1Dispatcher.h"


static NSUInteger const PiwikHTTPRequestTimeout = 5;


@implementation PiwikAFNetworking1Dispatcher


- (instancetype)initWithPiwikURL:(NSURL*)piwikURL {
  self = [super initWithBaseURL:piwikURL];
  if (self) {
    // Do nothing right now
  }
  return self;
}

// TODO: This code should be reviewed and updated or removed


- (void)sendSingleEventToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  //NSLog(@"Dispatch event with AFNetworking");
  
  self.parameterEncoding = AFFormURLParameterEncoding;
  
  NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:[path lastPathComponent] parameters:parameters];

  [self sendRequest:request success:successBlock failure:failureBlock];
  
}


- (void)sendbatchEventsToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
 
  self.parameterEncoding = AFJSONParameterEncoding;
  
  NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST" path:[path lastPathComponent] parameters:parameters];
  
  [self sendRequest:request success:successBlock failure:failureBlock];
  
}


- (void)sendRequest:(NSURLRequest*)request success:(void (^)())successBlock failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  request.timeoutInterval = PiwikHTTPRequestTimeout;
  
  //NSLog(@"Request %@", request);
  //NSLog(@"Request headers %@", [request allHTTPHeaderFields]);
  //NSLog(@"Request body %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
  
  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                 
      //NSLog(@"Successfully sent stats to Piwik server");
      successBlock();
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
      //NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
      failureBlock([self shouldAbortdispatchForNetworkError:error]);
      
    }];
  
  [self enqueueHTTPRequestOperation:operation];

}


// Should the dispatch be aborted and pending events rescheduled
// Subclasses can overwrite too change behaviour
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
