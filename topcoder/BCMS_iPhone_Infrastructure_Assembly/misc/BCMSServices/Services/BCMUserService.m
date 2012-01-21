//
//  BCMUserService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUserService.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMUser.h"
#import "BCMUserSearchFilter.h"
#import "BCMUtilityService.h"
#import "NSManagedObject+JSON.h"

@implementation BCMUserService

/* Logins the user.
 * @param userName User name.
 * @param password Password.
 * @param groupId Group id.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Authentication token if logged in successfully, otherwise <code>nil</code>.
 */
- (NSString*)loginWith:(NSString*)userName
           andPassword:(NSString*)password
               asGroup:(NSNumber*)groupId
                 error:(NSError**)error {
    return [self remote:@"POST"
                   path:[NSString stringWithFormat:@"login?username=%@&passwordHash=%@&groupId=%@", userName, password, groupId]
                   data:nil
                  error:error];
}

/* Logouts the user.
 * @param userId the Id of user to logout
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)logout:(NSNumber *)userId withToken:(NSString*)token
         error:(NSError**)error {
    NSNumber* result = [self remote:@"POST"
                               path:[NSString stringWithFormat:@"%@/logout?userId=%@", token, userId]
                               data:nil
                              error:error];
    return [result boolValue];
}

/** Gets <code>BCMUser</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getUsersWith:(NSString*)token
                   atStartCount:(NSUInteger)startCount
                    andPageSize:(NSUInteger)pageSize
                          error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMUser"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/** Gets <code>BCMUser</code>s from the local persistence, using given filter, with given fetch size and fetch offset,
 * @param token Authentication token.
 * @param filter Search filter.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)searchUsersWith:(NSString*)token
                         forFilter:(BCMUserSearchFilter*)filter
                      atStartCount:(NSUInteger)startCount
                       andPageSize:(NSUInteger)pageSize
                             error:(NSError**)error {
    NSMutableArray* subpredicates = [NSMutableArray array];

    if (filter.userId) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"id == %@", filter.userId]];
    }
    if (filter.employeeName) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"employeeName CONTAINS[c] %@", filter.employeeName]];
    }
    if (filter.userGroup) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"%@ IN groups", filter.userGroup]];
    }
    
    NSPredicate* predicate = [[[NSCompoundPredicate alloc] initWithType:NSCompoundPredicateTypeFromBCMFilterRule(filter.rule)
                                                          subpredicates:subpredicates] autorelease];
    
    BCMServicesLog(@"(BCMUserService searchUsersWith:forFilter:atStartCount:andPageSize:error:): Predicate %@", predicate);
    
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMUser"
                                                  withPredicate:predicate
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/**
 * Creates new user.
 * @param user User.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createUser:(BCMUser*)user
              withToken:(NSString*)token
                  error:(NSError**)error {
    
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:user
                                      URI:[NSString stringWithFormat:@"users"]
                                    token:token
                                    error:error];
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes user.
 * @param userId User id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteUser:(NSNumber*)userId
         withToken:(NSString*)token
             error:(NSError**)error {
    
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:userId
                                URI:[NSString stringWithFormat:@"users/%@", userId]
                      forEntityName:@"BCMUser"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates user.
 * @param user User.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateUser:(BCMUser*)user
         withToken:(NSString*)token
             error:(NSError**)error {
    
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:user
                              URI:[NSString stringWithFormat:@"users/%@", user.id]
                       withParent:nil
                            token:token
                            error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Refresh all user entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Refresh users from remote service
    //
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    NSError* remoteError = nil;
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMUser" error:&remoteError];
    BOOL res = [self refreshPagedDataForEntity:@"BCMUser" 
                                         since: lastRefresh 
                                           URI:@"users?sortBy=&sortAsc=true" 
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
    res = [utilityServ setLastRefreshTimeFor:@"BCMUser" error:&remoteError];
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
 * Factory method for producing <code>BCMUser</code> entity to use with <code>createUser</code>.
 * @return New <code>BCMUser</code> object.
 */
- (BCMUser*)user {
    return (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                   inManagedObjectContext:self.managedObjectContext];
}

@end
