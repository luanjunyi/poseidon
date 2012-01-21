//
//  BCMAreaOfficeServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMAreaOfficeServiceTest.h"

#import "NSManagedObject+JSON.h"
#import "BCMAreaOfficeService.h"
#import "NSManagedObjectContext+Utility.h"

#import "SBJsonWriter.h"

@implementation BCMAreaOfficeServiceTest

/**
 * Tests that <code>BCMAreaOfficeService.getAreaOfficesWith</code> returns valid data.
 */
- (void)testGetAreaOfficesWith {
    // insert area office into local context
    BCMAreaOffice* office = (BCMAreaOffice*)[self insertEntityFromFixture:@"BCMAreaOffice"];
    office = (BCMAreaOffice*)[self insertEntityFromFixture:@"BCMAreaOffice"];;
    office.id = [NSNumber numberWithInt: 100];
    office = (BCMAreaOffice*)[self insertEntityFromFixture:@"BCMAreaOffice"];;
    office.id = [NSNumber numberWithInt: 200];
    office = (BCMAreaOffice*)[self insertEntityFromFixture:@"BCMAreaOffice"];;
    office.id = [NSNumber numberWithInt: 300];
    
    NSError* error = nil;
    BCMPagedResult* result = [areaOfficeService getAreaOfficesWith:[self authToken]
                                                      atStartCount:0
                                                       andPageSize:2
                                                             error:&error];

    STAssertTrue([result.values count] > 0, @"No objects returned");
    STAssertTrue([[result.values lastObject] isKindOfClass:[BCMAreaOffice class]], @"Invalid object returned");
    STAssertTrue(result.startCount == 0, @"result.startCount incorrectly set");
    STAssertTrue(result.pageSize == 2, @"result.pageSize incorrectly set");
    STAssertTrue(result.totalCount > [result.values count], @"result.totalSize incorrectly set");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMAreaOfficeService.createAreaOffice</code> creates new object.
 */
- (void)testCreateAreaOffice {
    NSError* error = nil;
    
    // insert area office into local context
    BCMAreaOffice* newAreaOffice = [areaOfficeService areaOffice];
    NSString *name = @"Test area office";
    newAreaOffice.name = name;
    
    NSNumber* createdId = [areaOfficeService createAreaOffice:newAreaOffice
                                                    withToken:[self authToken]
                                                        error:&error];
    STAssertNotNil(createdId, @"Could not create area office (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMAreaOffice"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found");
    STAssertEqualObjects([result.values.lastObject id], createdId, @"Wrong object found in loca store");

    // Cleanup test object.
    BOOL deleted = [areaOfficeService deleteAreaOffice:createdId
                                             withToken:[self authToken]
                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete area office (%@)", error);
}

/**
 * Tests that <code>BCMAreaOfficeService.deleteAreaOffice</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteAreaOffice {
    NSError* error = nil;

    // insert area office into local context    
    [self insertEntityFromFixture:@"BCMAreaOffice"];
    
    BCMAreaOffice* newAreaOffice = [self anyAreaOffice];
    newAreaOffice.name = @"Test area office";
    newAreaOffice.contacts = [NSSet setWithObject:[self anyContact]];
    
    NSNumber* createdId = [areaOfficeService createAreaOffice:newAreaOffice
                                                    withToken:[self authToken]
                                                        error:&error];
    STAssertNotNil(createdId, @"Could not create area office (%@)", error);

    // Test that deletion works.
    BOOL deleted = [areaOfficeService deleteAreaOffice:createdId
                                             withToken:[self authToken]
                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete area office (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMAreaOffice"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 0, @"Entity was not deleted from local store, entities: %i", result.values.count);
    NSLog(@"%@", [result.values.lastObject toJSON]);
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [areaOfficeService deleteAreaOffice:createdId
                                                withToken:[self authToken]
                                                    error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMAreaOfficeService.addAreaOfficeContact</code> adds contact to area office.
 */
- (void)testAddAreaOfficeContact {
    NSError* error = nil;
    
    // insert area office into local context
    [self insertEntityFromFixture:@"BCMAreaOffice"];
    
    BCMAreaOffice* areaOffice = [self anyAreaOffice];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact"];
    
    NSNumber* createdId = [areaOfficeService addAreaOfficeContact:newContact
                                                     toAreaOffice:areaOffice.id
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(createdId, @"Could not add contact to area office (%@)", error);
    NSSet* contacts = areaOffice.contacts;
    STAssertTrue(contacts.count > 0, @"Failed to add contact");
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(c, @"Contact was not added");
    STAssertEqualObjects(c.name, @"Contact #21", @"Wrong contact's name saved");
    STAssertEqualObjects(c.primaryNumber, @"PrimaryNumber #21", @"Wrong contact's primary number saved");

    
    // Cleanup test object.
    BOOL deleted = [areaOfficeService deleteAreaOfficeContact:createdId
                                               fromAreaOffice:areaOffice.id
                                                    withToken:[self authToken]
                                                        error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from area office (%@)", error);
}

/**
 * Tests that <code>BCMAreaOfficeService.deleteAreaOfficeContact</code> deletes contact from area office.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteAreaOfficeContact {
    NSError* error = nil;
    
    // insert area office into local context
    [self insertEntityFromFixture:@"BCMAreaOffice"];
    
    BCMAreaOffice* areaOffice = [self anyAreaOffice];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact"];
    
    NSNumber* createdId = [areaOfficeService addAreaOfficeContact:newContact
                                                     toAreaOffice:areaOffice.id
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(createdId, @"Could not add contact to area office (%@)", error);
    
    // Test that deletion works.
    BOOL deleted = [areaOfficeService deleteAreaOfficeContact:createdId
                                               fromAreaOffice:areaOffice.id
                                                    withToken:[self authToken]
                                                        error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from area office (%@)", error);
    NSSet* contacts = areaOffice.contacts;
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNil(c, @"Contact was not removed");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [areaOfficeService deleteAreaOfficeContact:createdId
                                                  fromAreaOffice:areaOffice.id
                                                       withToken:[self authToken]
                                                           error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMAreaOfficeService.updateAreaOfficeContact</code> updates contact.
 */
- (void)testUpdateAreaOfficeContact {
    NSError* error = nil;
    
    // insert area office into local context
    [self insertEntityFromFixture:@"BCMAreaOffice"];
    
    BCMAreaOffice* areaOffice = [self anyAreaOffice];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact"];
    
    NSNumber* createdId = [areaOfficeService addAreaOfficeContact:newContact
                                                     toAreaOffice:areaOffice.id
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(createdId, @"Could not add contact to area office (%@)", error);
    
    // Get created contact
    // Fetch object with given id.
    NSSet* contacts = areaOffice.contacts;
    BCMContact* updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Failed to get contact to be updated");
    
    // Test update.
    NSString* modifiedName = @"Modified name";
    updateContact.name = modifiedName;
    BOOL updated = [areaOfficeService updateAreaOfficeContact:updateContact
                                                forAreaOffice:areaOffice.id
                                                    withToken:[self authToken]
                                                        error:&error];    
    STAssertTrue(updated, @"Could not update contact for area office (%@)", error);
    contacts = areaOffice.contacts;
    updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Contact not found in local context, id: %@", createdId);
    STAssertEqualObjects(updateContact.name, modifiedName, @"Failed to update contact localy");
}

/**
 * Tests entities refresh from remote web service endpoint
 */
-(void)testRefreshData {
    // do refresh data
    //
    NSError *error = nil;
    BOOL res = [areaOfficeService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh BCMAreaOffice entities, error (%@)", error);
    
    // check if local store refreshed
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMAreaOffice"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];

    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
}


@end
