//
//  PiwikDebugDispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikDebugDispatcher.h"


@implementation PiwikDebugDispatcher


- (void)dispatchWithMethod:(NSString*)method
                      path:(NSString*)path
                parameters:(NSDictionary*)parameters
                   success:(void (^)())successBlock
                   faliure:(void (^)(BOOL shouldContinue))faliureBlock {
  
  NSLog(@"Dispatch event with debug dispatcher");
  
  NSLog(@"Request: \n%@\n%@", path, parameters);
  
  successBlock();
  
}


@end
