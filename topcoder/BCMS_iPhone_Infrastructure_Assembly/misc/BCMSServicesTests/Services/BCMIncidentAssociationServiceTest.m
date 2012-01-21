//
//  BCMIncidentAssociationServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentAssociationServiceTest.h"

#import "NSManagedObjectContext+Utility.h"

@implementation BCMIncidentAssociationServiceTest

/**
 * Tests that <code>BCMIncidentService.getIncidentAssociationsWith</code> returns valid data.
 */
- (void)testGetIncidentAssociationsWith {
    // insert test objects
    BCMIncidentAssociation* association = (BCMIncidentAssociation*)[self insertEntityFromFixture:@"BCMIncidentAssociation"];
    association = (BCMIncidentAssociation*)[self insertEntityFromFixture:@"BCMIncidentAssociation"];
    association.id = [NSNumber numberWithInteger:100];
    association = (BCMIncidentAssociation*)[self insertEntityFromFixture:@"BCMIncidentAssociation"];
    association.id = [NSNumber numberWithInteger:100];
    association = (BCMIncidentAssociation*)[self insertEntityFromFixture:@"BCMIncidentAssociation"];
    association.id = [NSNumber numberWithInteger:100];
    
    NSError* error = nil;
    BCMPagedResult* result = [incidentAssociationService getIncidentAssociationsWith:[self authToken]
                                                                        atStartCount:0
                                                                         andPageSize:2
                                                                               error:&error];
    
    STAssertTrue([result.values count] > 0, @"No objects returned");
    STAssertTrue([[result.values lastObject] isKindOfClass:[BCMIncidentAssociation class]], @"Invalid object returned");
    STAssertTrue(result.startCount == 0, @"result.startCount incorrectly set");
    STAssertTrue(result.pageSize == 2, @"result.pageSize incorrectly set");
    STAssertTrue(result.totalCount > [result.values count], @"result.totalSize incorrectly set");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMIncidentAssociationService.createIncidentAssociation</code> creates new object.
 */
- (void)testCreateIncidentAssociation {
    NSError* error = nil;
    
    // Create test incidents.
    BCMIncident* primaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* primaryIncidentId = [incidentService createIncident:primaryIncident
                                                withToken:[self authToken]
                                                    error:&error];
    STAssertNotNil(primaryIncidentId, @"Could not create incident for test (%@)", error);
    BCMIncident* secondaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* secondaryIncidentId = [incidentService createIncident:secondaryIncident
                                                withToken:[self authToken]
                                                    error:&error];
    STAssertNotNil(secondaryIncidentId, @"Could not create incident for test (%@)", error);
    
    // create association
    BCMIncidentAssociation* newIncidentAssociation = [incidentAssociationService incidentAssociation];
    newIncidentAssociation.primaryIncidentReport = primaryIncident;
    newIncidentAssociation.secondaryIncidentReports = [NSSet setWithObject:secondaryIncident];
    
    NSNumber* createdId = [incidentAssociationService createIncidentAssociation:newIncidentAssociation
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(createdId, @"Could not create incident association (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAssociation"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found");
    STAssertTrue([result.values containsObject:newIncidentAssociation], @"Wrong object found in local store");
    STAssertEqualObjects(primaryIncident, newIncidentAssociation.primaryIncidentReport, @"Wrong primary insident in association");
    STAssertTrue([newIncidentAssociation.secondaryIncidentReports containsObject:secondaryIncident], @"Wrong secondary incident in association");
    
    // Cleanup test object.
    BOOL deleted = [incidentAssociationService deleteIncidentAssociation:primaryIncidentId 
                                                           withSecondary:secondaryIncidentId
                                                               withToken:[self authToken] 
                                                                   error:&error];    
    STAssertTrue(deleted, @"Could not delete incident association (%@)", error);
    
    error = nil;
    deleted = [incidentService deleteIncident:primaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
    
    error = nil;
    deleted = [incidentService deleteIncident:secondaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
}

/**
 * Tests that <code>BCMIncidentAssociationService.deleteIncidentAssociation</code> deletes object.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentAssociation {
    NSError* error = nil;
    
    // Create test incidents.
    BCMIncident* primaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* primaryIncidentId = [incidentService createIncident:primaryIncident
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(primaryIncidentId, @"Could not create incident for test (%@)", error);
    BCMIncident* secondaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* secondaryIncidentId = [incidentService createIncident:secondaryIncident
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(secondaryIncidentId, @"Could not create incident for test (%@)", error);
    
    // create association
    //
    BCMIncidentAssociation* newIncidentAssociation = [incidentAssociationService incidentAssociation];
    newIncidentAssociation.primaryIncidentReport = primaryIncident;
    newIncidentAssociation.secondaryIncidentReports = [NSSet setWithObject:secondaryIncident];
    
    NSNumber* createdId = [incidentAssociationService createIncidentAssociation:newIncidentAssociation
                                                                      withToken:[self authToken]
                                                                          error:&error];
    STAssertNotNil(createdId, @"Could not create incident association (%@)", error);
    
    // Test deletion.
    BOOL deleted = [incidentAssociationService deleteIncidentAssociation:primaryIncidentId 
                                                           withSecondary:secondaryIncidentId
                                                               withToken:[self authToken] 
                                                                   error:&error];    
    STAssertTrue(deleted, @"Could not delete incident association (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAssociation"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 0, @"Entity was not deleted from local store");
    
    // Test that deleting non-existing association fails.
    BOOL shouldFail = [incidentAssociationService deleteIncidentAssociation:primaryIncidentId 
                                                           withSecondary:secondaryIncidentId
                                                               withToken:[self authToken] 
                                                                   error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
    
    // cleanup test objects
    error = nil;
    deleted = [incidentService deleteIncident:primaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
    
    error = nil;
    deleted = [incidentService deleteIncident:secondaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
}

/**
 * Tests add incident assciation semanthics object.
 */
- (void)testAddIncidentAssociation {
    NSError* error = nil;
    
    // Create test incidents.
    BCMIncident* primaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* primaryIncidentId = [incidentService createIncident:primaryIncident
                                                        withToken:[self authToken]
                                                            error:&error];
    STAssertNotNil(primaryIncidentId, @"Could not create incident for test (%@)", error);
    BCMIncident* secondaryIncident = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    error = nil;
    NSNumber* secondaryIncidentId = [incidentService createIncident:secondaryIncident
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(secondaryIncidentId, @"Could not create incident for test (%@)", error);
    
    // create association
    //
    BCMIncidentAssociation* association = [incidentAssociationService incidentAssociation];
    association.primaryIncidentReport = primaryIncident;
    association.secondaryIncidentReports = [NSSet setWithObject:secondaryIncident];
    
    error = nil;
    NSNumber* createdId = [incidentAssociationService createIncidentAssociation:association
                                                                      withToken:[self authToken]
                                                                          error:&error];
    STAssertNotNil(createdId, @"Could not create incident association (%@)", error);
    
    // Test add other one.
    error = nil;
    BCMIncident* secondaryIncident2 = (BCMIncident*)[self insertEntityFromFixture:@"BCMIncident"];
    
    NSNumber* secondaryIncident2Id = [incidentService createIncident:secondaryIncident2
                                                          withToken:[self authToken]
                                                              error:&error];
    STAssertNotNil(secondaryIncidentId, @"Could not create incident for test (%@)", error);
    
    error = nil;
    BOOL res = [incidentAssociationService addIncidentAssociation:primaryIncidentId 
                                                    withSecondary:secondaryIncident2Id 
                                                        withToken:[self authToken] 
                                                            error:&error ];
    STAssertTrue(res, @"Failed to add incident association", error);
    
    // check if local store was updated
    STAssertTrue([association.secondaryIncidentReports containsObject:secondaryIncident2], @"Local store was not updated");
    STAssertTrue([association.secondaryIncidentReports count] == 2, @"Wrong sendary reports count found in association");
    
    // cleanup test objects
    error = nil;
    BOOL deleted = [incidentAssociationService deleteIncidentAssociation:primaryIncidentId 
                                                      withSecondary:secondaryIncidentId
                                                          withToken:[self authToken] 
                                                              error:&error];    
    STAssertTrue(deleted, @"Could not delete incident association (%@)", error);
    
    error = nil;
    deleted = [incidentAssociationService deleteIncidentAssociation:primaryIncidentId 
                                                      withSecondary:secondaryIncident2Id
                                                          withToken:[self authToken] 
                                                              error:&error];    
    STAssertTrue(deleted, @"Could not delete incident association (%@)", error);
    
    
    error = nil;
    deleted = [incidentService deleteIncident:primaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
    
    error = nil;
    deleted = [incidentService deleteIncident:secondaryIncidentId withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
    
    error = nil;
    deleted = [incidentService deleteIncident:secondaryIncident2Id withToken:[self authToken] error:&error ];
    STAssertTrue(deleted, @"Could not delete incident (%@)", error);
}

/**
 * Tests entities refresh from remote web service endpoint
 */
-(void)testRefreshData {
    // do refresh data
    //
    NSError *error = nil;
    BOOL res = [incidentAssociationService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh BCMIncidentAssociation entities, error (%@)", error);
    
    // check if local store refreshed
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAssociation"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    
    STAssertTrue(result.values.count > 0, @"Failed to refresh data from remote service, error (%@)", error);
}

@end
