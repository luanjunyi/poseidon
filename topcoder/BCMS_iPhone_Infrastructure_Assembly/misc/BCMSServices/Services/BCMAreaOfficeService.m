//
//  BCMAreaOfficeService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMAreaOfficeService.h"

#import "NSManagedObjectContext+Utility.h"
#import "NSManagedObject+JSON.h"
#import "BCMAreaOffice.h"
#import "BCMContact.h"
#import "BCMUtilityService.h"

@implementation BCMAreaOfficeService

/** Gets <code>BCMAreaOffice</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getAreaOfficesWith:(NSString*)token
                         atStartCount:(NSUInteger)startCount
                          andPageSize:(NSUInteger)pageSize
                                error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMAreaOffice"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/**
 * Creates new area office.
 * @param areaOffice Area office.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createAreaOffice:(BCMAreaOffice*)areaOffice
                    withToken:(NSString*)token
                        error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:areaOffice
                                      URI:[NSString stringWithFormat:@"areaOffices"]
                                    token:token
                                    error:error];
    areaOffice.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes area office.
 * @param areaOfficeId Area office id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteAreaOffice:(NSNumber*)areaOfficeId
               withToken:(NSString*)token
                   error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:areaOfficeId
                                    URI:[NSString stringWithFormat:@"areaOffices/%@", areaOfficeId]
                          forEntityName:@"BCMAreaOffice"
                                  token:token
                                  error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Adds contact to area office.
 *
 * N.B. The placeholder contact object will be removed from local store as result of this operation. To
 * get actual stored contact object use returned contact Id.
 *
 * @param contact Contact.
 * @param areaOfficeId Id of the area office.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the added entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)addAreaOfficeContact:(BCMContact*)contact
                     toAreaOffice:(NSNumber*)areaOfficeId
                        withToken:(NSString*)token
                            error:(NSError**)error {
    
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self addObject:contact
                                    to:@"BCMAreaOffice"
                                   URI:[NSString stringWithFormat:@"areaOffices/%@/contacts", areaOfficeId]
                                 token:token
                                 error:error];
    contact.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes contact from area office.
 * @param contactId Id of the contact.
 * @param areaOfficeId Id of the area office.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteAreaOfficeContact:(NSNumber*)contactId
                 fromAreaOffice:(NSNumber*)areaOfficeId
                      withToken:(NSString*)token
                          error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:contactId
                                URI:[NSString stringWithFormat:@"areaOffices/%@/contacts/%@", areaOfficeId, contactId]
                      forEntityName:@"BCMContact"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates contact for area office.
 * @param contact Contact.
 * @param areaOfficeId Id of the area office.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)updateAreaOfficeContact:(BCMContact*)contact
                  forAreaOffice:(NSNumber*)areaOfficeId
                      withToken:(NSString*)token
                          error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:contact
                              URI:[NSString stringWithFormat:@"areaOffices/%@/contacts/%@", areaOfficeId, contact.id]
                       withParent:@"BCMAreaOffice"
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
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMAreaOffice" error:&remoteError];
    BOOL res = [self refreshPagedDataForEntity:@"BCMAreaOffice" 
                                         since: lastRefresh 
                                           URI:@"areaOffices?sortBy=&sortAsc=true" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMAreaOffice" error:&remoteError];
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
 * Factory method for producing <code>BCMAreaOffice</code> entity to use with <code>createAreaOffice</code>.
 * @return New <code>BCMAreaOffice</code> object.
 */
- (BCMAreaOffice*)areaOffice {
    return (BCMAreaOffice*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMAreaOffice"
                                                         inManagedObjectContext:self.managedObjectContext];
}

@end
