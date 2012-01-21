//
//  BCMLookupService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

/**
 * Service providing lookup for various entities.
 * @author proxi
 * @version 1.0
 */
@interface BCMLookupService : BCMSService

/** Gets all <code>BCMIncidentStatus</code>es from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentStatuses:(NSString*)token
                        error:(NSError**)error;

/** Gets all <code>BCMContactRole</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getContactRoles:(NSString*)token
                    error:(NSError**)error;

/** Gets all <code>BCMIncidentType</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentTypes:(NSString*)token
                     error:(NSError**)error;

/** Gets all <code>BCMAdditionalInfo</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getIncidentAdditionalInfos:(NSString*)token
                               error:(NSError**)error;

/** Gets all <code>BCMUserGroup</code>s from the local persistence.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> if successful, otherwise <code>nil</code>.
 */
- (NSSet*)getUserGroups:(NSString*)token
                  error:(NSError**)error;

/**
 * Refresh all relevant entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error;

@end
