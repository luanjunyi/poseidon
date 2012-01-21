//
//  BCMConveneRoomServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMConveneRoomServiceTest.h"
#import "NSManagedObjectContext+Utility.h"

@implementation BCMConveneRoomServiceTest

/**
 * Tests that <code>BCMConveneRoomService.getConveneRoomsWith</code> returns valid data.
 */
- (void)testGetConveneRoomsWith {
    BCMConveneRoom* room = (BCMConveneRoom*)[self insertEntityFromFixture:@"BCMConveneRoom"];
    room = (BCMConveneRoom*)[self insertEntityFromFixture:@"BCMConveneRoom"];
    room.id = [NSNumber numberWithInt: 100];
    room = (BCMConveneRoom*)[self insertEntityFromFixture:@"BCMConveneRoom"];
    room.id = [NSNumber numberWithInt: 200];
    room = (BCMConveneRoom*)[self insertEntityFromFixture:@"BCMConveneRoom"];
    room.id = [NSNumber numberWithInt: 300];
    
    NSError* error = nil;
    BCMPagedResult* result = [conveneRoomService getConveneRoomsWith:[self authToken]
                                                        atStartCount:0
                                                         andPageSize:2
                                                               error:&error];
    
    STAssertTrue([result.values count] > 0, @"No objects returned");
    STAssertTrue([[result.values lastObject] isKindOfClass:[BCMConveneRoom class]], @"Invalid object returned");
    STAssertTrue(result.startCount == 0, @"result.startCount incorrectly set");
    STAssertTrue(result.pageSize == 2, @"result.pageSize incorrectly set");
    STAssertTrue(result.totalCount > [result.values count], @"result.totalSize incorrectly set");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMConveneRoomService.createConveneRoom</code> creates new object.
 */
- (void)testCreateConveneRoom {
    NSError* error = nil;
    
    // insert object
    BCMConveneRoom* newConveneRoom = [conveneRoomService conveneRoom];
    NSString* name = @"Test convene room";
    newConveneRoom.name = name;
    
    NSNumber* createdId = [conveneRoomService createConveneRoom:newConveneRoom
                                                      withToken:[self authToken]
                                                          error:&error];
    STAssertNotNil(createdId, @"Could not create convene room (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMConveneRoom"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found");
    STAssertEqualObjects([result.values.lastObject name], name, @"Wrong object found in loca store");
    
    // Cleanup test object.
    BOOL deleted = [conveneRoomService deleteConveneRoom:createdId
                                               withToken:[self authToken]
                                                   error:&error];    
    STAssertTrue(deleted, @"Could not delete convene room (%@)", error);
}

/**
 * Tests that <code>BCMConveneRoomService.deleteConveneRoom</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteConveneRoom {
    NSError* error = nil;
    
    // Create test object.
    BCMConveneRoom* newConveneRoom = [conveneRoomService conveneRoom];
    newConveneRoom.name = @"Test convene room";
    
    NSNumber* createdId = [conveneRoomService createConveneRoom:newConveneRoom
                                                           withToken:[self authToken]
                                                               error:&error];
    STAssertNotNil(createdId, @"Could not create convene room (%@)", error);
    
    // Test that deletion works.
    BOOL deleted = [conveneRoomService deleteConveneRoom:createdId
                                               withToken:[self authToken]
                                                   error:&error];    
    STAssertTrue(deleted, @"Could not delete convene room (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMConveneRoom"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 0, @"Entity was not deleted from local store");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [conveneRoomService deleteConveneRoom:createdId
                                                  withToken:[self authToken]
                                                      error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMConveneRoomService.addConveneRoomContact</code> adds contact to convene room.
 */
- (void)testAddConveneRoomContact {
    NSError* error = nil;

    // insert convene room object
    [self insertEntityFromFixture:@"BCMConveneRoom"];
    
    BCMConveneRoom* conveneRoom = [self anyConveneRoom];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];

    NSNumber* createdId = [conveneRoomService addConveneRoomContact:newContact
                                                      toConveneRoom:conveneRoom.id
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(createdId, @"Could not add contact to convene room (%@)", error);
    NSSet* contacts = conveneRoom.cmtContacts;
    STAssertTrue(contacts.count > 0, @"Failed to add contact");
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(c, @"Contact was not added");
    STAssertEqualObjects(c.name, @"Contact #9", @"Wrong contact's name saved");
    STAssertEqualObjects(c.primaryNumber, @"PrimaryNumber #9", @"Wrong contact's primary number saved");

    // Cleanup test object.
    BOOL deleted = [conveneRoomService deleteConveneRoomContact:createdId
                                                fromConveneRoom:conveneRoom.id
                                                      withToken:[self authToken]
                                                          error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from convene room (%@)", error);
}

/**
 * Tests that <code>BCMConveneRoomService.deleteConveneRoomContact</code> deletes contact from convene room.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteConveneRoomContact {
    NSError* error = nil;
    
    // insert convene room object
    [self insertEntityFromFixture:@"BCMConveneRoom"];
    
    BCMConveneRoom* conveneRoom = [self anyConveneRoom];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];
    
    NSNumber* createdId = [conveneRoomService addConveneRoomContact:newContact
                                                      toConveneRoom:conveneRoom.id
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(createdId, @"Could not add contact to convene room (%@)", error);
    
    // Test that deletion works.
    BOOL deleted = [conveneRoomService deleteConveneRoomContact:createdId
                                                fromConveneRoom:conveneRoom.id
                                                      withToken:[self authToken]
                                                          error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from convene room (%@)", error);
    NSSet* contacts = conveneRoom.cmtContacts;
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNil(c, @"Contact was not removed");

    // Test that deleting non-existing object fails.
    BOOL shouldFail = [conveneRoomService deleteConveneRoomContact:createdId
                                                fromConveneRoom:conveneRoom.id
                                                      withToken:[self authToken]
                                                          error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMConveneRoomService.updateConveneRoomContact</code> updates contact.
 */
- (void)testUpdateConveneRoomContact {
    NSError* error = nil;
    
    // insert convene room object
    [self insertEntityFromFixture:@"BCMConveneRoom"];
    
    BCMConveneRoom* conveneRoom = [self anyConveneRoom];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];
    
    NSNumber* createdId = [conveneRoomService addConveneRoomContact:newContact
                                                      toConveneRoom:conveneRoom.id
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(createdId, @"Could not add contact to convene room (%@)", error);
    
    // get created contact
    NSSet* contacts = conveneRoom.cmtContacts;
    BCMContact* updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Failed to get contact to be updated");

    // Test update.
    NSString* modifiedName = @"Modified name";
    updateContact.name = modifiedName;
    BOOL updated = [conveneRoomService updateConveneRoomContact:updateContact
                                                 forConveneRoom:conveneRoom.id
                                                      withToken:[self authToken]
                                                          error:&error];    
    STAssertTrue(updated, @"Could not update contact for convene room (%@)", error);
    contacts = conveneRoom.cmtContacts;
    updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Contact not found in local context, id: %@", createdId);
    STAssertEqualObjects(updateContact.name, modifiedName, @"Failed to update contact localy");

    // Cleanup test object.
    BOOL deleted = [conveneRoomService deleteConveneRoomContact:createdId
                                                fromConveneRoom:conveneRoom.id
                                                      withToken:[self authToken]
                                                          error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from convene room (%@)", error);
}

/**
 * Tests entities refresh from remote web service endpoint
 */
-(void)testRefreshData {
    // do refresh data
    //
    NSError *error = nil;
    BOOL res = [conveneRoomService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh BCMConveneRoom entities, error (%@)", error);
    
    // check if local store refreshed
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMConveneRoom"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
}
@end
