//
//  PiwikAFNetworkingDispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikAFNetworkingDispatcher.h"
#import "AFHTTPClient.h"

static NSUInteger const PiwikHTTPRequestTimeout = 5;


@interface PiwikAFNetworkingDispatcher ()

@property (nonatomic, strong) AFHTTPClient *httpClient;

@end



@implementation PiwikAFNetworkingDispatcher


- (void)dispathWithMethod:(NSString*)method
                     path:(NSString*)path
               parameters:(NSDictionary*)parameters
                  success:(void (^)())successBlock
                  faliure:(void (^)(BOOL shouldContinue))faliureBlock {
  
  NSLog(@"Dispatch event with AFNetworking");
  
  if (!self.httpClient) {
    self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[path stringByDeletingLastPathComponent]]];
  }
  
  self.httpClient.parameterEncoding = [method isEqualToString:@"GET"] ? AFFormURLParameterEncoding : AFJSONParameterEncoding;
  
  NSMutableURLRequest *request = [self.httpClient requestWithMethod:method path:[path lastPathComponent] parameters:parameters];
  request.timeoutInterval = PiwikHTTPRequestTimeout;

  NSLog(@"Request %@", request);
  NSLog(@"Request headers %@", [request allHTTPHeaderFields]);
  NSLog(@"Request body %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
  
  //        NSLocale *locale = [NSLocale currentLocale];
  //        DLog(@"Language %@", [locale objectForKey:NSLocaleLanguageCode]);
  //        DLog(@"Country %@", [locale objectForKey:NSLocaleCountryCode]);
  
  AFHTTPRequestOperation *operation = [self.httpClient HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
      NSLog(@"Successfully sent stats to Piwik server");
      
      successBlock();
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
      NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
      
      faliureBlock([self shouldAbortdispatchForNetworkError:error]);
      
    }];
  
  [self.httpClient enqueueHTTPRequestOperation:operation];
  
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
