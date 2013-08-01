//
//  EventEntity.h
//  PiwikTracker
//
//  Created by Mattias Levin on 7/30/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventEntity : NSManagedObject

@property (nonatomic, retain) NSData * requestParameters;
@property (nonatomic, retain) NSDate * date;

@end
