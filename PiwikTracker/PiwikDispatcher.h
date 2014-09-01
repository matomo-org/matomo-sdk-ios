//
//  PiwikDispatcher.h
//  PiwikTracker
//
//  Created by Mattias Levin on 29/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//
@protocol PiwikDispatcher

// TODO Split on two methods, single send and batch send

- (void)dispathWithMethod:(NSString*)method
                     path:(NSString*)path
               parameters:(NSDictionary*)parameters
                  success:(void (^)())successBlock
                  faliure:(void (^)(BOOL shouldContinue))faliureBlock;

@end
