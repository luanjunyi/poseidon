//
//  BCMUtilityService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

/**
 * Service responsible for managing refresh log and local cache clearance.
 * @author proxi
 * @version 1.0
 */
@interface BCMUtilityService : BCMSService

/**
 * Clears all the local entities, including the BCMRefreshLog.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)clearLocalData:(NSError**)error;

/** Queries the BCMRefreshLog to find last refresh time of the given entity name.
 * @param entityName Name of the entity to query for.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Time of the last refresh of the entity or <code>nil</code> if no refresh is recorded or error occured.
 */
- (NSDate*)getLastRefreshTimeFor:(NSString*)entityName error:(NSError**)error;

/** Update the BCMRefreshLog to set last refresh time of the given entity name. The current time will be used.
 * @param entityName Name of the entity to set last refresh time for.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)setLastRefreshTimeFor:(NSString*)entityName error:(NSError**)error;

@end
