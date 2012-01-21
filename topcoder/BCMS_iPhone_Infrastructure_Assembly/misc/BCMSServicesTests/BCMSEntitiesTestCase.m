//
//  BCMSEntitiesTestCase.m
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSEntitiesTestCase.h"

#import "SBJson.h"
#import "NSManagedObject+JSON.h"
#import "BCMPagedResult.h"

@implementation BCMSEntitiesTestCase

/**
 * Set up environment for testing.
 */
- (void)setUp {
    [super setUp];

    testBundle = [[NSBundle bundleForClass:[self class]] retain];
    
    testConfiguration = [[NSDictionary dictionaryWithContentsOfFile:[testBundle pathForResource:@"TestConfiguration" ofType:@"plist"]] retain];

    // Set-up code here.
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:testBundle]] retain];
    STAssertNotNil(managedObjectModel, @"Error setting up MOC");

    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Add an in-memory persistent store to the coordinator.    
    NSError* addStoreError = nil;
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&addStoreError];
    STAssertNil(addStoreError, @"Error setting up in-memory store");

    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
}

/**
 * Tear down test environment.
 */
- (void)tearDown {
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];

    [testConfiguration release];

    [testBundle release];
    
    [super tearDown];
}

- (NSDictionary*)readFixture:(NSString*)path {
    SBJsonParser* jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSString* filePath = [testBundle pathForResource:path ofType:nil];
    NSString* jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary* jsonObjects = [jsonParser objectWithString:jsonString error:nil];
    STAssertNotNil(jsonObjects, @"Could not read fixture data");
    STAssertTrue([jsonObjects isKindOfClass:[NSDictionary class]], @"Fixture data is not a dictionary");
    return jsonObjects;
}

/**
 * Reads and inserts into management context entity with specified name
 * @param entityName the entity name
 */
- (NSManagedObject*)insertEntityFromFixture: (NSString* )entityName {
    NSString * fixturePath = [NSString stringWithFormat:@"%@.json", entityName];
    return [self insertEntityFromFixture:fixturePath forName:entityName];
}

/**
 * Reads and inserts into management context entity with specified name
 * @param entityName the entity name
 * @param fixturePath the fixture name
 */
- (NSManagedObject*)insertEntityFromFixture: (NSString*) fixturePath forName:(NSString* )entityName {
    NSDictionary* fixture = [self readFixture:fixturePath];
    
    NSManagedObject* entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    return entity;
}

@end
