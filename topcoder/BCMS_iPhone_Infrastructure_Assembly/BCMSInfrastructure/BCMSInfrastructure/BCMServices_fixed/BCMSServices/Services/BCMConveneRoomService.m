//
//  BCMConveneRoomService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMConveneRoomService.h"

#import "BCMUtilityService.h"
#import "NSManagedObjectContext+Utility.h"
#import "BCMConveneRoom.h"
#import "BCMContact.h"

@implementation BCMConveneRoomService

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
                                 error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMConveneRoom"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/**
 * Creates new convene room.
 * @param conveneRoom Convene room.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createConveneRoom:(BCMConveneRoom*)conveneRoom
                     withToken:(NSString*)token
                         error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:conveneRoom
                                      URI:[NSString stringWithFormat:@"conveneRooms"]
                                    token:token
                                    error:error];
    conveneRoom.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes convene room.
 * @param conveneRoomId Convene rrom id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteConveneRoom:(NSNumber*)conveneRoomId
                withToken:(NSString*)token
                    error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:conveneRoomId
                                URI:[NSString stringWithFormat:@"conveneRooms/%@", conveneRoomId]
                      forEntityName:@"BCMConveneRoom"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

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
                             error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self addObject:contact
                                    to:@"BCMConveneRoom"
                                   URI:[NSString stringWithFormat:@"conveneRooms/%@/contacts", conveneRoomId]
                                 token:token
                                 error:error];
    contact.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

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
                           error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:contactId
                                    URI:[NSString stringWithFormat:@"conveneRooms/%@/contacts/%@", conveneRoomId, contactId]
                          forEntityName:@"BCMContact"
                                  token:token
                                  error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

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
                           error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:contact
                              URI:[NSString stringWithFormat:@"conveneRooms/%@/contacts/%@", conveneRoomId, contact.id]
                       withParent:@"BCMConveneRoom"
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
    NSError* remoteError = nil;
    NSString* URI = [NSString stringWithFormat: @"%@/conveneRooms?", token];
    BOOL res = [self refreshPagedDataForEntity:@"BCMConveneRoom" URI:URI error:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // set refresh log record
    remoteError = nil;
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    res = [utilityServ setLastRefreshTimeFor:@"BCMConveneRoom" error:&remoteError];
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
 * Factory method for producing <code>BCMConveneRoom</code> entity to use with <code>createConveneRoom</code>.
 * @return New <code>BCMConveneRoom</code> object.
 */
- (BCMConveneRoom*)conveneRoom {
    return (BCMConveneRoom*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMConveneRoom"
                                                          inManagedObjectContext:self.managedObjectContext];
}

@end
