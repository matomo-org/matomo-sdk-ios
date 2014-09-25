//
//  PiwikNSURLSessionDispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikNSURLSessionDispatcher.h"


static NSUInteger const PiwikHTTPRequestTimeout = 5;


@implementation PiwikNSURLSessionDispatcher


- (void)sendSingleEventToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  NSLog(@"Dispatch single event with NSURLSession dispatcher");
    
  NSMutableArray *parameterPair = [NSMutableArray arrayWithCapacity:parameters.count];
  [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [parameterPair addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
  }];
  
  NSString *requestURL = [NSString stringWithFormat:@"%@?%@", path, [[parameterPair componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:PiwikHTTPRequestTimeout];
  request.HTTPMethod = @"GET";
  
  [self sendRequest:request success:successBlock failure:failureBlock];
  
}


- (void)sendBatchEventsToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  NSLog(@"Dispatch batch events with NSURLSession dispatcher");
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:PiwikHTTPRequestTimeout];
  request.HTTPMethod = @"POST";
  
  NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
  
  NSError *error;
  request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
  
  [self sendRequest:request success:successBlock failure:failureBlock];
  
}


- (void)sendRequest:(NSURLRequest*)request success:(void (^)())successBlock failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (!error) {
      successBlock();
    } else {
      failureBlock([self shouldAbortdispatchForNetworkError:error]);
    }
  }];
  
  [task resume];
  
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
