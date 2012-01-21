//
//  BCMIncidentNoteServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentNoteServiceTest.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentNoteService.h"
#import "BCMIncidentNote.h"
#import "BCMIncidentService.h"

@implementation BCMIncidentNoteServiceTest

/**
 * Tests <code>BCMIncidentNoteService.getIncidentNotesForIncident</code> method.
 */
- (void)testGetIncidentNotesForIncident {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentNote* newIncidentNote = [incidentNoteService incidentNoteForIncident:incident];
    newIncidentNote.addedBy = @"Test user";
    newIncidentNote.addedDate = [NSDate date];
    newIncidentNote.note = @"Test note";
    
    NSNumber* createdId = [incidentNoteService createIncidentNote:newIncidentNote
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident Note (%@)", error);
    
    // Test get.
    NSSet* result = [incidentNoteService getIncidentNotesForIncident:incident.id
                                                           withToken:[self authToken]
                                                               error:&error];
    STAssertNotNil(result, @"Error occured (%@)", error);
    STAssertTrue([result containsObject:newIncidentNote], @"Note was not added to incident");
    
    // Cleanup test object.
    BOOL deleted = [incidentNoteService deleteIncidentNote:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident Note (%@)", error);
}

/**
 * Tests that <code>BCMIncidentNoteService.createIncidentNote</code> creates new object.
 */
- (void)testCreateIncidentNote {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentNote* newIncidentNote = [incidentNoteService incidentNoteForIncident:incident];
    newIncidentNote.addedBy = @"Test user";
    newIncidentNote.addedDate = [NSDate date];
    newIncidentNote.note = @"Test note";
    
    NSNumber* createdId = [incidentNoteService createIncidentNote:newIncidentNote
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident Note (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentNote"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue([result.values containsObject:newIncidentNote], @"Wrong object found in local store");
    
    // Cleanup test object.
    BOOL deleted = [incidentNoteService deleteIncidentNote:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident Note (%@)", error);
}

/**
 * Tests that <code>BCMIncidentNoteService.deleteIncidentNote</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentNote {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentNote* newIncidentNote = [incidentNoteService incidentNoteForIncident:incident];
    newIncidentNote.addedBy = @"Test user";
    newIncidentNote.addedDate = [NSDate date];
    newIncidentNote.note = @"Test note";
    
    NSNumber* createdId = [incidentNoteService createIncidentNote:newIncidentNote
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident Note (%@)", error);
    
    // Test deletion.
    BOOL deleted = [incidentNoteService deleteIncidentNote:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident Note (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentUpdate"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertFalse([result.values containsObject:newIncidentNote], @"Deleted object found in local store");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentNoteService deleteIncidentNote:createdId
                                                        withToken:[self authToken]
                                                            error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMIncidentNoteService.NoteIncidentNote</code> updates object.
 */
- (void)testUpdateIncidentNote {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    BCMIncidentNote* newIncidentNote = [incidentNoteService incidentNoteForIncident:incident];
    newIncidentNote.addedBy = @"Test user";
    newIncidentNote.addedDate = [NSDate date];
    newIncidentNote.note = @"Test note";
    
    NSNumber* createdId = [incidentNoteService createIncidentNote:newIncidentNote
                                                            withToken:[self authToken]
                                                                error:&error];
    STAssertNotNil(createdId, @"Could not create incident Note (%@)", error);
    
    // Test update.
    newIncidentNote.note = @"Updated note";
    BOOL updated = [incidentNoteService updateIncidentNote:newIncidentNote
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(updated, @"Could not update incident Note (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentNote"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue([result.values containsObject:newIncidentNote], @"Wrong object found in local store");
    
    // Cleanup test object.
    BOOL deleted = [incidentNoteService deleteIncidentNote:createdId
                                                     withToken:[self authToken]
                                                         error:&error];    
    STAssertTrue(deleted, @"Could not delete incident Note (%@)", error);
}

@end
