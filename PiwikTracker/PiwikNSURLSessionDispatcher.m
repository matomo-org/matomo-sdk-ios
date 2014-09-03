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


- (void)dispatchWithMethod:(NSString*)method
                      path:(NSString*)path
                parameters:(NSDictionary*)parameters
                   success:(void (^)())successBlock
                   faliure:(void (^)(BOOL shouldContinue))faliureBlock {
  
  NSLog(@"Dispatch event with NSURLSession dispatcher");
  
  // Create request
  NSMutableURLRequest *request = nil;
  if ([method isEqualToString:@"GET"]) {
    
    NSMutableArray *parameterPair = [NSMutableArray arrayWithCapacity:parameters.count];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      [parameterPair addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    NSString *path = [NSString stringWithFormat:@"?%@", [[parameterPair componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:PiwikHTTPRequestTimeout];
    request.HTTPMethod = @"GET";
    
  } else {
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:PiwikHTTPRequestTimeout];
    request.HTTPMethod = @"POST";
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
      
  }
  
  // Create session and task
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (!error) {
      successBlock();
    } else {
      faliureBlock(NO);
    }
  }];
  
  [task resume];
  
}


@end
