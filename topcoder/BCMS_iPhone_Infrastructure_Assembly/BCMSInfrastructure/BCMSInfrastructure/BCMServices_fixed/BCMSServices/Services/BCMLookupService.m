//
//  BCMLookupService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMLookupService.h"

#import "BCMUtilityService.h"
#import "NSManagedObjectContext+Utility.h"

@interface BCMLookupService (private)

/**
 * Method to refresh user groups list from remote web service
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 */
-(BOOL)refreshUserGroups:(NSError**)error;
/** Gets all objects of given entity from the local persistence.
 * @param entityName Entity name.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getObjectsForEntityName:(NSString*)entityName
                            error:(NSError**)error;
@end

@implementation BCMLookupService


/** Gets all <code>BCMIncidentStatus</code>es from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentStatuses:(NSString*)token
                        error:(NSError**)error {
    return [self getObjectsForEntityName:@"BCMIncidentStatus" error:error];
}

/** Gets all <code>BCMContactRole</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getContactRoles:(NSString*)token
                    error:(NSError**)error {
    return [self getObjectsForEntityName:@"BCMContactRole" error:error];
}

/** Gets all <code>BCMIncidentType</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentTypes:(NSString*)token
                     error:(NSError**)error {
    return [self getObjectsForEntityName:@"BCMIncidentType" error:error];
}

/** Gets all <code>BCMAdditionalInfo</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentAdditionalInfos:(NSString*)token
                               error:(NSError**)error {
    return [self getObjectsForEntityName:@"BCMAdditionalInfo" error:error];
}

/** Gets all <code>BCMUserGroup</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getUserGroups:(NSString*)token
                  error:(NSError**)error {
    NSError* remoteError = nil;
    BOOL res = [self refreshUserGroups:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return nil;
    }
    return [self getObjectsForEntityName:@"BCMUserGroup" error:error];
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
    // refresh BCMIncidentStatus
    //
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    NSError* remoteError = nil;
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMIncidentStatus" error:&remoteError];
    BOOL res = [self refreshPagedDataForEntity:@"BCMIncidentStatus" 
                                         since: lastRefresh 
                                           URI:@"incidentStatuses?" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMIncidentStatus" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // refresh BCMContactRole
    //
    remoteError = nil;
    lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMContactRole" error:&remoteError];
    res = [self refreshPagedDataForEntity:@"BCMContactRole" 
                                    since: lastRefresh 
                                      URI:@"contactRoles?" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMContactRole" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // refresh BCMIncidentType
    //
    remoteError = nil;
    lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMIncidentType" error:&remoteError];
    res = [self refreshPagedDataForEntity:@"BCMIncidentType" 
                                    since: lastRefresh 
                                      URI:@"incidentTypes?" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMIncidentType" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // refresh BCMAdditionInfo
    //
    remoteError = nil;
    lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMAdditionalInfo" error:&remoteError];
    res = [self refreshPagedDataForEntity:@"BCMAdditionalInfo" 
                                    since: lastRefresh 
                                      URI:@"incidentAdditionalInfos?" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMAdditionalInfo" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // refresh BCMUserGroup
    //
    remoteError = nil;
    res = [self refreshUserGroups:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // no errors detected
    return YES;
    
}

#pragma mark - Private methods implementation
/**
 * Method to refresh user groups list from remote web service
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 */
-(BOOL)refreshUserGroups:(NSError**)error {
    if (error) {
        *error = nil;
    }
    // refresh user groups
    //
    NSError* remoteError = nil;
    NSString* URI = @"/userGroups";
    BOOL res = [self refreshDataForEntity:@"BCMUserGroup" URI:URI error:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    // set refresh log record
    remoteError = nil;
    BCMUtilityService* utility = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    res = [utility setLastRefreshTimeFor:@"BCMUserGroup" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // no errors detected
    return YES;
}

/** Gets all objects of given entity from the local persistence.
 * @param entityName Entity name.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getObjectsForEntityName:(NSString*)entityName
                            error:(NSError**)error {
    NSArray* result = [self.managedObjectContext getObjectsForEntityName:entityName
                                                           withPredicate:nil
                                                         sortDescriptors:nil
                                                                   error:error];
    
    if (!result) {
        return nil;
    }
    
    return [NSSet setWithArray:result];
}

@end
