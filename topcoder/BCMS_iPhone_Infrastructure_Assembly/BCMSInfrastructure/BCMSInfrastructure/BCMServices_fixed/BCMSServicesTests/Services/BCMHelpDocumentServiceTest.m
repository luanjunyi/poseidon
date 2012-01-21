//
//  BCMHelpDocumentServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMHelpDocumentServiceTest.h"

#import "BCMHelpDocumentService.h"
#import "NSManagedObjectContext+Utility.h"

@implementation BCMHelpDocumentServiceTest

/**
 * Set up environment for testing.
 */
- (void)setUp {
    [super setUp];
    
    config = [testConfiguration objectForKey:@"BCMHelpDocumentServiceTest"];
}

/**
 * Tests get help documents with search text.
 */
-(void)testGetHelpDocumentsWith
{   
    NSError* error = nil;
    // test documents not found
    BCMPagedResult* pRes = [helpDocumentService getHelpDocumentsWith:[self authToken] forSearchText:@"searchText" atStartCount:0 andPageSize:10 error: &error];
    STAssertNotNil(pRes, @"Paged result expected when testing documents not found");
    STAssertTrue(pRes.totalCount == 0, @"Wrong total count returned");
    
    // store test documents
    BCMHelpDocument* entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.name = @"document1";
    entity.downloadLink = @"document1link";
    entity.searchText = @"searchText for document1";
    entity.documentShortDescription = @"document1 short description";
    
    entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                             inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:3];
    entity.name = @"document2";
    entity.downloadLink = @"document1link";
    entity.searchText = @"searchText for document2";
    entity.documentShortDescription = @"document2 short description";
    
    // test search documents
    pRes = [helpDocumentService getHelpDocumentsWith:[self authToken] forSearchText:@"document2" atStartCount:0 andPageSize:10 error: &error];
    STAssertNotNil(pRes, @"Paged result expected when testing documents not found");
    STAssertTrue(pRes.values.count == 1, @"One found document expected");
    BCMHelpDocument* doc = [pRes.values lastObject];
    STAssertNotNil(doc, @"Help document expected");
    STAssertEqualObjects(doc.name, @"document2", @"Wrong document found");
}

/**
 * Tests refresh help documents
 */
-(void)testRefreshData{
    // remove all local users if any
    NSError* error = nil;
    BOOL res = [managedObjectContext deleteAllObjectsForEntityName:@"BCMHelpDocument" error:&error];
    STAssertTrue(res, @"Failed to delete all help documents, error (%@)", error);
    
    error = nil;
    NSArray *docs = [managedObjectContext getObjectsForEntityName:@"BCMHelpDocument" withPredicate:nil sortDescriptors:nil error:&error];
    STAssertTrue(docs.count == 0, @"All help documents expected to be deleted, error (%@)", error);
    
    // do refresh data
    //
    error = nil;
    res = [helpDocumentService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh help documents, error (%@)", error);
    
    // check if help documents stored localy
    error = nil;
    docs = [managedObjectContext getObjectsForEntityName:@"BCMHelpDocument" withPredicate:nil sortDescriptors:nil error:&error];
    STAssertTrue(docs.count > 0, @"Failed to add help documents from remote service, error (%@)", error);
}

/**
 * Tests <code>BCMHelpDocumentService</code>.
 */
- (void)testDownload {
    NSError* error = nil;

    NSNumber* docId = [config objectForKey:@"downloadDocumentId"];
    NSData* documentData = [helpDocumentService downloadHelpDocumentWith:[self authToken]
                                                         forHelpDocument:docId
                                                                   error:&error];
    STAssertNotNil(documentData, @"Could not download document (%@)", error);
}

@end
