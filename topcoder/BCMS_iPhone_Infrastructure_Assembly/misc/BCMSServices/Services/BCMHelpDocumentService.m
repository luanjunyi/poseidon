//
//  BCMHelpDocumentService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMHelpDocumentService.h"

#import "BCMUtilityService.h"
#import "NSManagedObjectContext+Utility.h"
#import "NSManagedObject+JSON.h"

@implementation BCMHelpDocumentService

/** Gets <code>BCMHelpDocument</code>s for given search text from the local persistence,
 * with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param searchText Search text.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getHelpDocumentsWith:(NSString*)token
                          forSearchText:(NSString*)searchText
                           atStartCount:(NSUInteger)startCount
                            andPageSize:(NSUInteger)pageSize
                                  error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(searchText CONTAINS[c] %@) OR (documentShortDescription CONTAINS[c] %@)", searchText, searchText];
    
    BCMPagedResult* result = [self.managedObjectContext fetchObjectsForEntityName:@"BCMHelpDocument"
                                                                    withPredicate:predicate
                                                                         atOffset:startCount
                                                                    withBatchSize:pageSize
                                                                            error:error];
    return result;
}

/**
 * Loads the data for help document.
 * @param token Authentication token.
 * @param helpDocumentId Document id.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded <code>NSData</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (NSData*)downloadHelpDocumentWith:(NSString*)token
                    forHelpDocument:(NSNumber*)helpDocumentId
                              error:(NSError**)error {
    return [self download:[NSString stringWithFormat:@"helpDocuments/%i", [helpDocumentId intValue]]
                    token:nil
                    error:error];
}

/**
 * Refresh all help documents entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Refresh help documents from remote service
    //
    NSError* remoteError = nil;
    BOOL res = [self refreshPagedDataForEntity:@"BCMHelpDocument" URI:@"helpDocuments?searchText=%25" error:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // set refresh log record
    remoteError = nil;
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    res = [utilityServ setLastRefreshTimeFor:@"BCMHelpDocument" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // no errors detected
    return YES;
}
@end
