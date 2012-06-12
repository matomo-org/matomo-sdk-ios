//
//  Pageview.m
//  PiwikTracker
//
//  Created by Mattias Levin on 5/13/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import "PTEvent.h"


@implementation PTEvent

@dynamic eventData;
@dynamic timestamp;


// Set the timestamp when inserting the managed object the first time
- (void)awakeFromInsert {
  //NSLog(@"awakeFromInsert");
  [super awakeFromInsert];
  // Set time stamp, needs to implement FIFO behaviour
  self.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
}


@end
