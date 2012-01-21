//
//  BCMIncidentCategoryService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentCategoryService.h"

#import "BCMUtilityService.h"
#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentCategory.h"
#import "BCMContact.h"

@implementation BCMIncidentCategoryService

/** Gets <code>BCMIncidentCategory</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getIncidentCategoriesWith:(NSString*)token
                                atStartCount:(NSUInteger)startCount
                                 andPageSize:(NSUInteger)pageSize
                                       error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMIncidentCategory"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/**
 * Creates new incident category.
 * @param incidentCategory Incident category.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentCategory:(BCMIncidentCategory*)incidentCategory
                          withToken:(NSString*)token
                              error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:incidentCategory
                          URI:[NSString stringWithFormat:@"incidentCategories"]
                        token:token
                        error:error];
    incidentCategory.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes incident category.
 * @param incidentCategoryId Incident category.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentCategory:(NSNumber*)incidentCategoryId
                     withToken:(NSString*)token
                         error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:incidentCategoryId
                                URI:[NSString stringWithFormat:@"incidentCategories/%@", incidentCategoryId]
                      forEntityName:@"BCMIncidentCategory"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Adds contact to incident category.
 *
 * N.B. The placeholder contact object will be removed from local store as result of this operation. To
 * get actual stored contact object use returned contact Id.
 *
 * @param contact Contact.
 * @param incidentCategoryId Id of the incident category.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the added entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)addIncidentCategoryContact:(BCMContact*)contact
                     toIncidentCategory:(NSNumber*)incidentCategoryId
                              withToken:(NSString*)token
                                  error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self addObject:contact
                                    to:@"BCMIncidentCategory"
                                   URI:[NSString stringWithFormat:@"incidentCategories/%@/contacts", incidentCategoryId]
                                 token:token
                                 error:error];
    contact.id = result;
    [self.managedObjectContext unlock];
    
    return result;
    
}

/**
 * Deletes contact from incident category.
 * @param contactId Id of the contact.
 * @param incidentCategoryId Id of the incident category.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentCategoryContact:(NSNumber*)contactId
                 fromIncidentCategory:(NSNumber*)incidentCategoryId
                            withToken:(NSString*)token
                                error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:contactId
                                URI:[NSString stringWithFormat:@"incidentCategories/%@/contacts/%@", incidentCategoryId, contactId]
                      forEntityName:@"BCMContact"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates contact for incident category.
 * @param contact Contact.
 * @param incidentCategoryId Id of the incident category.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)updateIncidentCategoryContact:(BCMContact*)contact
                  forIncidentCategory:(NSNumber*)incidentCategoryId
                            withToken:(NSString*)token
                                error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:contact
                          URI:[NSString stringWithFormat:@"incidentCategories/%@/contacts/%@", incidentCategoryId, contact.id]
                       withParent:@"BCMIncidentCategory"
                        token:token
                        error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Refresh all relevant entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Refresh entities from remote service
    //
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    NSError* remoteError = nil;
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMIncidentCategory" error:&remoteError];
    BOOL res = [self refreshPagedDataForEntity:@"BCMIncidentCategory" 
                                         since: lastRefresh 
                                           URI:@"incidentCategories?sortBy=&sortAsc=true" 
                                         token:token
                                         error:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // set refresh log record
    remoteError = nil;
    res = [utilityServ setLastRefreshTimeFor:@"BCMIncidentCategory" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // no errors detected
    return YES;
}

/**
 * Factory method for producing <code>BCMIncidentCategory</code> entity to use with <code>createIncidentCategory</code>.
 * @return New <code>BCMIncidentCategory</code> object.
 */
- (BCMIncidentCategory*)incidentCategory {
    return (BCMIncidentCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentCategory"
                                                               inManagedObjectContext:self.managedObjectContext];
}

@end
