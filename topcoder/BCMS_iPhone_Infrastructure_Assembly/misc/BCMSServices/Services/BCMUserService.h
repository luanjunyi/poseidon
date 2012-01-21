//
//  BCMUserService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMUser;
@class BCMUserSearchFilter;

/**
 * Service responsible for login and managing <code>BCMUser</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMUserService : BCMSService

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
                 error:(NSError**)error;

/* Logouts the user.
 * @param userId the Id of user to logout
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)logout:(NSNumber *)userId withToken:(NSString*)token
         error:(NSError**)error;

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
                          error:(NSError**)error;

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
                             error:(NSError**)error;

/**
 * Creates new user.
 * @param user User.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createUser:(BCMUser*)user
              withToken:(NSString*)token
                  error:(NSError**)error;

/**
 * Deletes user.
 * @param userId User id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteUser:(NSNumber*)userId
         withToken:(NSString*)token
             error:(NSError**)error;

/**
 * Updates user.
 * @param user User.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateUser:(BCMUser*)user
         withToken:(NSString*)token
             error:(NSError**)error;

/**
 * Refresh all user entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error;

/**
 * Factory method for producing <code>BCMUser</code> entity to use with <code>createUser</code>.
 * @return New <code>BCMUser</code> object.
 */
- (BCMUser*)user;

@end
