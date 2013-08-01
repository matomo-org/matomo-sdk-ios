//
//  EventEntity.m
//  PiwikTracker
//
//  Created by Mattias Levin on 7/30/13.
//
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
