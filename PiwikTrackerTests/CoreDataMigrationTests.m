//
//  CoreDataMigrationTests.m
//  PiwikTracker
//
//  Created by Mattias Levin on 23/05/15.
//  Copyright (c) 2015 Mattias Levin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>

@interface CoreDataMigrationTests : XCTestCase
@end

@implementation CoreDataMigrationTests

- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
}


- (void)tearDown {
  // Put teardown code here; it will be run once, after the last test case.
  [super tearDown];
}


- (void)migrateDataFromStoreWithName:(NSString*)name {
  
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSURL *storeURL = [bundle URLForResource:name withExtension:@"sqlite"];
  
  XCTAssertNotNil(storeURL, @"Cannot find %@.sqlite", name);
  
  NSURL *modelURL = [bundle URLForResource:@"piwiktracker" withExtension:@"momd"];
  NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  XCTAssertNotNil(managedObjectModel, @"Cannot load model");
  
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                                              initWithManagedObjectModel:managedObjectModel];
  
  NSDictionary *options = @{
                            NSMigratePersistentStoresAutomaticallyOption: @(YES),
                            NSInferMappingModelAutomaticallyOption: @(YES)
                            };
  
  NSError *error;
  NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                configuration:nil
                                                                                          URL:storeURL
                                                                                      options:options
                                                                                        error:&error];
  
  XCTAssertNotNil(persistentStore, @"Cannot load persistentStore: %@", [error localizedDescription]);
  
}


- (void)testDataMigrationFromV1 {
  [self migrateDataFromStoreWithName:@"piwiktracker_v1"];
}



@end
