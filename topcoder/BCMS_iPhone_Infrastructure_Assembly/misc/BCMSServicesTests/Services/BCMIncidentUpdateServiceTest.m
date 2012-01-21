//
//  BCMIncidentUpdateServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentUpdateServiceTest.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentUpdateService.h"
#import "BCMIncidentUpdate.h"
#import "BCMIncidentService.h"

@implementation BCMIncidentUpdateServiceTest

/**
 * Tests <code>BCMIncidentUpdateService.getIncidentUpdatesForIncident</code> method.
 */
- (void)testGetIncidentUpdatesForIncident {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);
    
    // Test get.
    NSSet* result = [incidentUpdateService getIncidentUpdatesForIncident:incident.id
                                                               withToken:[self authToken]
                                                                   error:&error];
    STAssertNotNil(result, @"Error occured (%@)", error);
    STAssertTrue([result containsObject:newIncidentUpdate], @"Update was not added to incident");
    
    // Cleanup test object.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident update (%@)", error);
}

/**
 * Tests that <code>BCMIncidentUpdateService.createIncidentUpdate</code> creates new object.
 */
- (void)testCreateIncidentUpdate {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentUpdate"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue([result.values containsObject:newIncidentUpdate], @"Wrong object found in local store");
    
    // Cleanup test object.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident update (%@)", error);
}

/**
 * Tests that <code>BCMIncidentUpdateService.deleteIncidentUpdate</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentUpdate {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);
    
    // Test deletion.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident update (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentUpdate"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertFalse([result.values containsObject:newIncidentUpdate], @"Deleted object found in local store");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentUpdateService deleteIncidentUpdate:createdId
                                                        withToken:[self authToken]
                                                            error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMIncidentUpdateService.updateIncidentUpdate</code> updates object.
 */
- (void)testUpdateIncidentUpdate {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);

    // Test update.
    newIncidentUpdate.comment = @"Updated comment";
    BOOL updated = [incidentUpdateService updateIncidentUpdate:newIncidentUpdate
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(updated, @"Could not update incident update (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentUpdate"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue([result.values containsObject:newIncidentUpdate], @"Wrong object found in local store");

    // Cleanup test object.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident update (%@)", error);
}

/**
 * Tests <code>BCMIncidentUpdateService.resendIncidentUpdate</code> method.
 */
- (void)testResendIncidentUpdate {
    NSError* error = nil;

    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);

    newIncidentUpdate.alertSent = NO;
    BOOL updated = [incidentUpdateService updateIncidentUpdate:newIncidentUpdate
                                                     withToken:[self authToken]
                                                         error:&error];
    STAssertTrue(updated, @"Could not update incident update (%@)", error);
    
    [self insertEntityFromFixture:@"BCMUserGroup"];
    BOOL resent = [incidentUpdateService resendIncidentUpdate:newIncidentUpdate.id
                                                     toGroups:[NSSet setWithObject:[self anyUserGroup]]
                                                    withToken:[self authToken]
                                                        error:&error];    
    STAssertTrue(resent, @"Could not resend incident update (%@)", error);
    STAssertTrue([newIncidentUpdate.alertSent boolValue], @"alertSent was not set");
    
    // Cleanup test object.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident update (%@)", error);
}

/**
 * Tests <code>BCMIncidentUpdateService.getLatestIncidentUpdateOfIncident</code> method.
 */
- (void)testGetLatestIncidentUpdateOfIncident {    
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];

    BCMIncident* incident = [self anyIncident];
    BCMIncidentUpdate* newIncidentUpdate = [incidentUpdateService incidentUpdateForIncident:incident];
    newIncidentUpdate.alertSent = NO;
    newIncidentUpdate.comment = @"Test comment";
    newIncidentUpdate.updatedBy = @"Test updater";
    newIncidentUpdate.updatedDate = [NSDate date];
    
    NSNumber* createdId = [incidentUpdateService createIncidentUpdate:newIncidentUpdate
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident update (%@)", error);

    // Test that latest's update date is latest.
    BCMIncidentUpdate* latestIncidentUpdate = [incidentUpdateService getLatestIncidentUpdateOfIncident:incident.id
                                                                                             withToken:[self authToken]
                                                                                                 error:&error];
    STAssertNotNil(latestIncidentUpdate, @"Error occured (%@)", error);
    for (BCMIncidentUpdate* update in incident.updates) {
        STAssertTrue([latestIncidentUpdate.updatedDate laterDate:update.updatedDate] == latestIncidentUpdate.updatedDate, @"Latest update is not the latest");
    }

    // Clean up test object.
    BOOL deleted = [incidentUpdateService deleteIncidentUpdate:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident note (%@)", error);
}

@end
