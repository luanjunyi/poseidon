//
//  BCMAreaOfficeService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMAreaOffice;
@class BCMContact;

/**
 * Service responsible for managing <code>BCMAreaOffice</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMAreaOfficeService : BCMSService

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
                                error:(NSError**)error;

/**
 * Creates new area office.
 * @param areaOffice Area office.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createAreaOffice:(BCMAreaOffice*)areaOffice
                    withToken:(NSString*)token
                        error:(NSError**)error;

/**
 * Deletes area office.
 * @param areaOfficeId Area office id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteAreaOffice:(NSNumber*)areaOfficeId
               withToken:(NSString*)token
                   error:(NSError**)error;

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
                            error:(NSError**)error;

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
                          error:(NSError**)error;

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
 * Factory method for producing <code>BCMAreaOffice</code> entity to use with <code>createAreaOffice</code>.
 * @return New <code>BCMAreaOffice</code> object.
 */
- (BCMAreaOffice*)areaOffice;

@end
