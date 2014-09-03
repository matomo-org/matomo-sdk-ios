//
//  PiwikDebugDispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikDebugDispatcher.h"


@implementation PiwikDebugDispatcher




- (void)sendSingleEventToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  NSLog(@"Dispatch single event with debug dispatcher");
  
  NSLog(@"Request: \n%@\n%@", path, parameters);
  
  successBlock();
  
}


- (void)sendBatchEventsToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  NSLog(@"Dispatch batch events with debug dispatcher");
  
  NSLog(@"Request: \n%@\n%@", path, parameters);
  
  successBlock();
  
}


@end
