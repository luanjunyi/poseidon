//
//  BCMIncidentServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentServiceTest.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentService.h"
#import "BCMIncident.h"
#import "BCMUser.h"

@implementation BCMIncidentServiceTest

/**
 * Tests that <code>BCMIncidentService.getIncidentsWith</code> returns valid data.
 */
- (void)testGetIncidentsWith {
    BCMIncident* incident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    incident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    incident.id = [NSNumber numberWithInteger:100];
    incident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    incident.id = [NSNumber numberWithInteger:200];
    incident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    incident.id = [NSNumber numberWithInteger:300];
    
    NSError* error = nil;
    BCMPagedResult* result = [incidentService getIncidentsWith:[self authToken]
                                                  atStartCount:0
                                                   andPageSize:2
                                                         error:&error];
    
    STAssertTrue([result.values count] > 0, @"No objects returned");
    STAssertTrue([[result.values lastObject] isKindOfClass:[BCMIncident class]], @"Invalid object returned");
    STAssertTrue(result.startCount == 0, @"result.startCount incorrectly set");
    STAssertTrue(result.pageSize == 2, @"result.pageSize incorrectly set");
    STAssertTrue(result.totalCount > [result.values count], @"result.totalSize incorrectly set");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests <code>BCMIncidentService.searchIncidentsWith</code>.
 */
- (void)testSearchIncidentsWith {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    BCMIncident* newIncident = [self anyIncident];
    
    NSNumber* createdId = [incidentService createIncident:newIncident
                                                withToken:[self authToken]
                                                    error:&error];
    STAssertNotNil(createdId, @"Could not create incident (%@)", error);
    
    // Search for the newly created incident using AND filter.
    BCMIncidentFilter* filter = [[[BCMIncidentFilter alloc] init] autorelease];
    filter.rule = BCMFilterRuleAND;
    filter.incident = newIncident.incident;
    filter.incidentNumber = newIncident.incidentNumber;

    BCMPagedResult* result = [incidentService searchIncidentsWith:[self authToken]
                                                        forFilter:filter
                                                     atStartCount:0
                                                      andPageSize:42
                                                            error:&error];
    STAssertNotNil(result, @"Error occured (%@)", error);
    STAssertTrue([result.values containsObject:newIncident], @"Search failed");

    // Search for the newly created incident using OR filter.
    filter.rule = BCMFilterRuleOR;
    filter.incidentNumber = [NSNumber numberWithInteger:888];
    BCMPagedResult* sameResult = [incidentService searchIncidentsWith:[self authToken]
                                                            forFilter:filter
                                                         atStartCount:0
                                                          andPageSize:42
                                                                error:&error];
    STAssertNotNil(sameResult, @"Error occured (%@)", error);
    STAssertTrue([sameResult.values containsObject:newIncident], @"Search failed");

    // Cleanup test object.
    BOOL deleted = [incidentService deleteIncident:createdId
                                         withToken:[self authToken]
                                             error:&error];    
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
}

/**
 * Tests <code>BCMIncidentService.getIncidentFor</code> method.
 */
- (void)testGetIncidentFor {
    NSError* error = nil;
    
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    
    BCMIncident* incidentFor = [incidentService getIncidentFor:incident.id withToken:[self authToken] error:&error];
    STAssertNotNil(incidentFor, @"Error occured (%@)", error);
    STAssertEqualObjects(incident, incidentFor, @"Invalid object");
}

/**
 * Tests that <code>BCMIncidentService.createIncident</code> creates new object.
 */
- (void)testCreateIncident {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    BCMIncident* newIncident = [self anyIncident];
    
    NSNumber* createdId = [incidentService createIncident:newIncident
                                                withToken:[self authToken]
                                                    error:&error];
    STAssertNotNil(createdId, @"Could not create incident (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncident"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found");
    STAssertTrue([result.values containsObject:newIncident], @"Wrong object found in local store");
    
    // Cleanup test object.
    BOOL deleted = [incidentService deleteIncident:createdId
                                         withToken:[self authToken]
                                             error:&error];    
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
}

/**
 * Tests that <code>BCMIncidentService.deleteIncident</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncident {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    BCMIncident* newIncident = [self anyIncident];
    
    NSNumber* createdId = [incidentService createIncident:newIncident
                                                withToken:[self authToken]
                                                    error:&error];
    STAssertNotNil(createdId, @"Could not create incident (%@)", error);
    
    // Test deletion.
    BOOL deleted = [incidentService deleteIncident:createdId
                                         withToken:[self authToken]
                                             error:&error];    
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncident"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 0, @"Entity was not deleted from local store");
    
    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentService deleteIncident:createdId
                                            withToken:[self authToken]
                                                error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests that <code>BCMIncidentService.updateIncident</code> updates object.
 */
- (void)testUpdateIncident {
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    BCMIncident* incident = [self anyIncident];
    
    incident.incident = [@"Test incident " stringByAppendingString:[self makeUUID]];
    BOOL updated = [incidentService updateIncident:incident
                                         withToken:[self authToken]
                                             error:&error];    
    STAssertTrue(updated, @"Could not update incident (%@)", error);
}

/**
 * Tests entities refresh from remote web service endpoint
 */
-(void)testRefreshData {
    // do refresh data
    //
    NSError *error = nil;
    BOOL res = [incidentService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh BCMIncident entities, error (%@)", error);
    
    // check if local store refreshed
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncident"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
    // check if incident updates refreshed
    result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentUpdate"
                                              withPredicate:nil
                                                   atOffset:0
                                              withBatchSize:5
                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
    // check if incident attachments refreshed
    result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAttachment"
                                              withPredicate:nil
                                                   atOffset:0
                                              withBatchSize:5
                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
    
    // check if incident notes refreshed
    result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentNote"
                                              withPredicate:nil
                                                   atOffset:0
                                              withBatchSize:5
                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
}

@end
