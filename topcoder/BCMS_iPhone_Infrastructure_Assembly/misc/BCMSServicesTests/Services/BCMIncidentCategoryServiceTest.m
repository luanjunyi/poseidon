//
//  BCMIncidentCategoryServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentCategoryServiceTest.h"
#import "NSManagedObjectContext+Utility.h"

@implementation BCMIncidentCategoryServiceTest

/**
 * Tests that <code>BCMIncidentCategoryService.getIncidentCategoriesWith</code> returns valid data.
 */
- (void)testGetIncidentCategoriesWith {
    // insert incidend categories into local context
    BCMIncidentCategory* category = (BCMIncidentCategory*)[self insertEntityFromFixture:@"BCMIncidentCategory"];
    category = (BCMIncidentCategory*)[self insertEntityFromFixture:@"BCMIncidentCategory"];
    category.id = [NSNumber numberWithInt: 100];
    category = (BCMIncidentCategory*)[self insertEntityFromFixture:@"BCMIncidentCategory"];
    category.id = [NSNumber numberWithInt: 200];
    category = (BCMIncidentCategory*)[self insertEntityFromFixture:@"BCMIncidentCategory"];
    category.id = [NSNumber numberWithInt: 300];
    
    
    NSError* error = nil;
    BCMPagedResult* result = [incidentCategoryService getIncidentCategoriesWith:[self authToken]
                                                                   atStartCount:0
                                                                    andPageSize:2
                                                                          error:&error];
    
    STAssertTrue([result.values count] > 0, @"No objects returned");
    STAssertTrue([[result.values lastObject] isKindOfClass:[BCMIncidentCategory class]], @"Invalid object returned");
    STAssertTrue(result.startCount == 0, @"result.startCount incorrectly set");
    STAssertTrue(result.pageSize == 2, @"result.pageSize incorrectly set");
    STAssertTrue(result.totalCount > [result.values count], @"result.totalSize incorrectly set");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMIncidentCategoryOffice.createIncidentCategory</code> creates new object.
 */
- (void)testCreateIncidentCategory {
    NSError* error = nil;
    
    // insert insident category into local context    
    BCMIncidentCategory* newIncidentCategory = [incidentCategoryService incidentCategory];
    NSString* name = @"Test incident category";
    newIncidentCategory.name = name;
    
    NSNumber* createdId = [incidentCategoryService createIncidentCategory:newIncidentCategory
                                                                withToken:[self authToken]
                                                                    error:&error];
    STAssertNotNil(createdId, @"Could not create incident category (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentCategory"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found");
    STAssertEqualObjects([result.values.lastObject name], name, @"Wrong object found in loca store");
    
    // Cleanup test object.
    BOOL deleted = [incidentCategoryService deleteIncidentCategory:createdId
                                                         withToken:[self authToken]
                                                             error:&error];    
    STAssertTrue(deleted, @"Could not delete incident category (%@)", error);
}

/**
 * Tests that <code>BCMIncidentCategoryService.deleteIncidentCategory</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentCategory {
    NSError* error = nil;
    
    // insert insident category into local context
    [self insertEntityFromFixture:@"BCMIncidentCategory"];
    
    // Create test object.
    BCMIncidentCategory* newIncidentCategory = [self anyIncidentCategory];
    newIncidentCategory.name = @"Test incident category";
    
    NSNumber* createdId = [incidentCategoryService createIncidentCategory:newIncidentCategory
                                                                withToken:[self authToken]
                                                                    error:&error];
    STAssertNotNil(createdId, @"Could not create incident category (%@)", error);
    
    // Test that deletion works.
    BOOL deleted = [incidentCategoryService deleteIncidentCategory:createdId
                                                         withToken:[self authToken]
                                                             error:&error];    
    STAssertTrue(deleted, @"Could not delete incident category (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentCategory"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 0, @"Entity was not deleted from local store");

    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentCategoryService deleteIncidentCategory:createdId
                                                            withToken:[self authToken]
                                                                error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMIncidentCategoryService.addIncidentCategoryContact</code> adds contact to incident category.
 */
- (void)testAddIncidentCategoryContact {
    NSError* error = nil;
    
    // Add incident category
    [self insertEntityFromFixture:@"BCMIncidentCategory"];
    
    BCMIncidentCategory* incidentCategory = [self anyIncidentCategory];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];
    
    NSNumber* createdId = [incidentCategoryService addIncidentCategoryContact:newContact
                                                           toIncidentCategory:incidentCategory.id
                                                                    withToken:[self authToken]
                                                                        error:&error];
    STAssertNotNil(createdId, @"Could not add contact to incident category (%@)", error);
    NSSet* contacts = incidentCategory.ismContacts;
    STAssertTrue(contacts.count > 0, @"Failed to add contact");
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(c, @"Contact was not added");
    STAssertEqualObjects(c.name, @"Contact #9", @"Wrong contact's name saved");
    STAssertEqualObjects(c.primaryNumber, @"PrimaryNumber #9", @"Wrong contact's primary number saved");
    
    // Cleanup test object.
    BOOL deleted = [incidentCategoryService deleteIncidentCategoryContact:createdId
                                                     fromIncidentCategory:incidentCategory.id
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from incident category (%@)", error);
}

/**
 * Tests that <code>BCMIncidentCategoryService.deleteIncidentCategoryContact</code> deletes contact from incident category.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentCategoryContact {
    NSError* error = nil;
    
    // Add incident category
    [self insertEntityFromFixture:@"BCMIncidentCategory"];
    
    BCMIncidentCategory* incidentCategory = [self anyIncidentCategory];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];
    
    NSNumber* createdId = [incidentCategoryService addIncidentCategoryContact:newContact
                                                           toIncidentCategory:incidentCategory.id
                                                                    withToken:[self authToken]
                                                                        error:&error];
    STAssertNotNil(createdId, @"Could not add contact to incident category (%@)", error);
    
    // Test that deletion works.
    BOOL deleted = [incidentCategoryService deleteIncidentCategoryContact:createdId
                                                     fromIncidentCategory:incidentCategory.id
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from incident category (%@)", error);
    NSSet* contacts = incidentCategory.ismContacts;
    BCMContact* c = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNil(c, @"Contact was not removed");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentCategoryService deleteIncidentCategoryContact:createdId
                                                     fromIncidentCategory:incidentCategory.id
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMIncidentCategoryService.updateIncidentCategoryContact</code> updates contact.
 */
- (void)testUpdateIncidentCategoryContact {
    NSError* error = nil;
    
    // Add incident category
    [self insertEntityFromFixture:@"BCMIncidentCategory"];
    
    BCMIncidentCategory* incidentCategory = [self anyIncidentCategory];
    BCMContact* newContact = (BCMContact*)[self insertEntityFromFixture:@"BCMContact_CMT.json" forName:@"BCMContact"];
    
    NSNumber* createdId = [incidentCategoryService addIncidentCategoryContact:newContact
                                                           toIncidentCategory:incidentCategory.id
                                                                    withToken:[self authToken]
                                                                        error:&error];
    STAssertNotNil(createdId, @"Could not add contact to incident category (%@)", error);
    
    // get created contact
    NSSet* contacts = incidentCategory.ismContacts;
    BCMContact* updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Failed to get contact to be updated");
    
    // Test update.
    NSString* modifiedName = @"Modified name";
    updateContact.name = modifiedName;
    BOOL updated = [incidentCategoryService updateIncidentCategoryContact:updateContact
                                                      forIncidentCategory:incidentCategory.id
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertTrue(updated, @"Could not update contact for  incident category (%@)", error);
    contacts = incidentCategory.ismContacts;
    updateContact = [self findBCMContactWithId:createdId inSet:contacts];
    STAssertNotNil(updateContact, @"Contact not found in local context, id: %@", createdId);
    STAssertEqualObjects(updateContact.name, modifiedName, @"Failed to update contact localy");

    // Cleanup test object.
    BOOL deleted = [incidentCategoryService deleteIncidentCategoryContact:createdId
                                                     fromIncidentCategory:incidentCategory.id
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertTrue(deleted, @"Could not delete contact from incident category (%@)", error);
}

/**
 * Tests entities refresh from remote web service endpoint
 */
-(void)testRefreshData {
    // do refresh data
    //
    NSError *error = nil;
    BOOL res = [incidentCategoryService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh BCMIncidentCategory entities, error (%@)", error);
    
    // check if local store refreshed
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentCategory"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
}

@end
