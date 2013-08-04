//
//  EventEntity.m
//  PiwikTracker
//
//  Created by Mattias Levin on 7/30/13.
//  Copyright 2013 Mattias Levin. All rights reserved.
//

#import "EventEntity.h"


@implementation EventEntity

@dynamic requestParameters;
@dynamic date;


- (void)awakeFromInsert {
  // Set date
  self.date = [NSDate date];
}


@end
