//
//  BCMSEntitiesTestCase.h
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <CoreData/CoreData.h>

/**
 * Base class for test cases in the module. Sets up test environment and provides
 * helper methods.
 */
@interface BCMSEntitiesTestCase : SenTestCase {
    NSBundle* testBundle;
    
    NSPersistentStoreCoordinator* persistentStoreCoordinator;
    NSManagedObjectContext* managedObjectContext;
    NSManagedObjectModel* managedObjectModel;
    
    NSDictionary* testConfiguration;
}

/**
 * Helper method to grab JSON test fixture.
 * @return NSDictionary representing fixture JSON data.
 */
- (NSDictionary*)readFixture:(NSString*)path;

/**
 * Reads and inserts into management context entity with specified name
 * @param entityName the entity name
 */
- (NSManagedObject*)insertEntityFromFixture: (NSString* )entityName;

/**
 * Reads and inserts into management context entity with specified name
 * @param entityName the entity name
 * @param fixture the fixture name
 */
- (NSManagedObject*)insertEntityFromFixture: (NSString*) fixturePath forName:(NSString* )entityName;

@end
