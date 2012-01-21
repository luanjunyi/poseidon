//
//  BCMIncidentAttachmentServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentAttachmentServiceTest.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentAttachmentService.h"

@implementation BCMIncidentAttachmentServiceTest

/**
 * Tests <code>BCMIncidentAttachmentService.getIncidentAttachmentsForIncident</code> method.
 */
- (void)testGetIncidentAttachmentsForIncident {    
    NSError* error = nil;

    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];

    BCMIncident* incident = [self anyIncident];
    
    NSData* attachmentData = [@"Lorem ipsum dolor" dataUsingEncoding:NSUTF8StringEncoding];
    
    BCMIncidentAttachment* newIncidentAttachment = [incidentAttachmentService uploadIncidentAttachment:@"test_filename.txt"
                                                                                               andData:attachmentData
                                                                                           forIncident:incident.id
                                                                                             withToken:[self authToken]
                                                                                                 error:&error];
    STAssertNotNil(newIncidentAttachment, @"Could not upload attachment (%@)", error);
    
    // Test get.
    NSSet* result = [incidentAttachmentService getIncidentAttachmentsForIncident:incident.id
                                                                       withToken:[self authToken]
                                                                           error:&error];
    STAssertNotNil(result, @"Error occured (%@)", error);
    STAssertTrue([result containsObject:newIncidentAttachment], @"Attachment was not added to incident");

    // Cleanup test object.
    BOOL deleted = [incidentAttachmentService deleteIncidentAttachment:newIncidentAttachment.id
                                                             withToken:[self authToken]
                                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete attachment (%@)", error);
}

/**
 * Tests <code>BCMIncidentAttachmentService.uploadIncidentAttachmentsForIncident</code> method.
 */
- (void)testUploadIncidentAttachment {    
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    
    NSData* attachmentData = [@"Lorem ipsum dolor" dataUsingEncoding:NSUTF8StringEncoding];
    
    BCMIncidentAttachment* newIncidentAttachment = [incidentAttachmentService uploadIncidentAttachment:@"test_filename.txt"
                                                                                               andData:attachmentData
                                                                                           forIncident:incident.id
                                                                                             withToken:[self authToken]
                                                                                                 error:&error];
    STAssertNotNil(newIncidentAttachment, @"Could not upload attachment (%@)", error);
    
    // Cleanup test object.
    BOOL deleted = [incidentAttachmentService deleteIncidentAttachment:newIncidentAttachment.id
                                                             withToken:[self authToken]
                                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete attachment (%@)", error);
}

/**
 * Tests <code>BCMIncidentAttachmentService.deleteIncidentAttachmentsForIncident</code> method.
 * Tests that deleting non-existing object fails.
 */
- (void)testDeleteIncidentAttachment {    
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    
    NSData* attachmentData = [@"Lorem ipsum dolor" dataUsingEncoding:NSUTF8StringEncoding];
    
    BCMIncidentAttachment* newIncidentAttachment = [incidentAttachmentService uploadIncidentAttachment:@"test_filename.txt"
                                                                                               andData:attachmentData
                                                                                           forIncident:incident.id
                                                                                             withToken:[self authToken]
                                                                                                 error:&error];
    STAssertNotNil(newIncidentAttachment, @"Could not upload attachment (%@)", error);
    
    // Test deletion.
    NSNumber* idToDelete = newIncidentAttachment.id;
    BOOL deleted = [incidentAttachmentService deleteIncidentAttachment:idToDelete
                                                             withToken:[self authToken]
                                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete attachment (%@)", error);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAttachment"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertFalse([result.values containsObject:newIncidentAttachment], @"Deleted object found in local store");

    // Test that deleting non-existing object fails.
    BOOL shouldFail = [incidentAttachmentService deleteIncidentAttachment:idToDelete
                                                                withToken:[self authToken]
                                                                    error:&error];    
    STAssertFalse(shouldFail, @"Could delete non-existing object");
    STAssertNotNil(error, @"Error not set");
}

/**
 * Tests <code>BCMIncidentAttachmentService.downloadIncidentAttachmentsForIncident</code> method.
 * Tests that downloaded data matches what was uploaded.
 */
- (void)testDownloadIncidentAttachment {    
    NSError* error = nil;
    
    // Create test incident.
    [self insertEntityFromFixture:@"BCMIncident"];
    
    BCMIncident* incident = [self anyIncident];
    
    NSData* attachmentData = [@"Lorem ipsum dolor" dataUsingEncoding:NSUTF8StringEncoding];
    
    BCMIncidentAttachment* newIncidentAttachment = [incidentAttachmentService uploadIncidentAttachment:@"test_filename.txt"
                                                                                               andData:attachmentData
                                                                                           forIncident:incident.id
                                                                                             withToken:[self authToken]
                                                                                                 error:&error];
    STAssertNotNil(newIncidentAttachment, @"Could not upload attachment (%@)", error);
    
    // Test download.
    NSData* downloadedData = [incidentAttachmentService downloadIncidentAttachment:newIncidentAttachment.id
                                                                         withToken:[self authToken]
                                                                             error:&error];
    STAssertNotNil(downloadedData, @"Could not download attachment (%@)", error);
    STAssertEqualObjects(downloadedData, attachmentData, @"Downloaded data differs from original");
    
    // Cleanup test object.
    BOOL deleted = [incidentAttachmentService deleteIncidentAttachment:newIncidentAttachment.id
                                                             withToken:[self authToken]
                                                                 error:&error];    
    STAssertTrue(deleted, @"Could not delete attachment (%@)", error);
}

@end
