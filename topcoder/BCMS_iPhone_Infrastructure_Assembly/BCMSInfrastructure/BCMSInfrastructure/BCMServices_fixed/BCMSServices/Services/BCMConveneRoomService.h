//
//  BCMConveneRoomService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMContact;
@class BCMConveneRoom;

/**
 * Service responsible for managing <code>BCMConveneRoom</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMConveneRoomService : BCMSService

/** Gets <code>BCMConveneRoom</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getConveneRoomsWith:(NSString*)token
                          atStartCount:(NSUInteger)startCount
                           andPageSize:(NSUInteger)pageSize
                                 error:(NSError**)error;

/**
 * Creates new convene room.
 * @param conveneRoom Convene room.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createConveneRoom:(BCMConveneRoom*)conveneRoom
                     withToken:(NSString*)token
                         error:(NSError**)error;

/**
 * Deletes convene room.
 * @param conveneRoomId Convene rrom id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteConveneRoom:(NSNumber*)conveneRoomId
                withToken:(NSString*)token
                    error:(NSError**)error;

/**
 * Adds contact to convene room.
 *
 * N.B. The placeholder contact object will be removed from local store as result of this operation. To
 * get actual stored contact object use returned contact Id.
 *
 * @param contact Contact.
 * @param conveneRoomId Id of the convene room.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the added entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)addConveneRoomContact:(BCMContact*)contact
                     toConveneRoom:(NSNumber*)conveneRoomId
                         withToken:(NSString*)token
                             error:(NSError**)error;

/**
 * Deletes contact from convene room.
 * @param contactId Id of the convene room.
 * @param conveneRoomId Id of the convene room.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteConveneRoomContact:(NSNumber*)contactId
                 fromConveneRoom:(NSNumber*)conveneRoomId
                       withToken:(NSString*)token
                           error:(NSError**)error;

/**
 * Updates contact in convene room.
 * @param contact Contact.
 * @param conveneRoomId Id of the convene room.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)updateConveneRoomContact:(BCMContact*)contact
                  forConveneRoom:(NSNumber*)conveneRoomId
                       withToken:(NSString*)token
                           error:(NSError**)error;

/**
 * Refresh all relevant entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error;

/**
 * Factory method for producing <code>BCMConveneRoom</code> entity to use with <code>createConveneRoom</code>.
 * @return New <code>BCMConveneRoom</code> object.
 */
- (BCMConveneRoom*)conveneRoom;

@end
