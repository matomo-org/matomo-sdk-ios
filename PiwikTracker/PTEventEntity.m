//
//  PTEventEntity.m
//  PiwikTracker
//
//  Created by Mattias Levin on 8/6/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "PTEventEntity.h"


@implementation PTEventEntity

@dynamic date;
@dynamic requestParameters;


- (void)awakeFromInsert {
  // Set date
  self.date = [NSDate date];
}


@end
