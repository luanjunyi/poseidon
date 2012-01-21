//
//  BCMIncidentUpdateService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMIncident;
@class BCMIncidentUpdate;

/**
 * Service responsible for managing <code>BCMIncidentUpdate</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentUpdateService : BCMSService

/**
 * Returns all the <code>BCMIncidentUpdate</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch updates for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentUpdate</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentUpdatesForIncident:(NSNumber*)incidentId
                              withToken:(NSString*)token
                                  error:(NSError**)error;

/**
 * Creates new incident update.
 * @param incidentUpdate Incident update.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentUpdate:(BCMIncidentUpdate*)incidentUpdate
                        withToken:(NSString*)token
                            error:(NSError**)error;

/**
 * Deletes incident update.
 * @param incidentUpdateId Incident update id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentUpdate:(NSNumber*)incidentUpdateId
                   withToken:(NSString*)token
                       error:(NSError**)error;

/**
 * Updates incident update.
 * @param incidentUpdate Incident update.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncidentUpdate:(BCMIncidentUpdate*)incidentUpdate
                   withToken:(NSString*)token
                       error:(NSError**)error;

/**
 * Resends incident update to specified groups.
 * @param incidentUpdateId Incident update id.
 * @param groups Groups to send to.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)resendIncidentUpdate:(NSNumber*)incidentUpdateId
                    toGroups:(NSSet*)groups
                   withToken:(NSString*)token
                       error:(NSError**)error;

/**
 * Returns lates incident update of given incident.
 * @param incidentId Incident id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Latest incident update or <code>nil</code>.
 */
- (BCMIncidentUpdate*)getLatestIncidentUpdateOfIncident:(NSNumber*)incidentId
                                              withToken:(NSString*)token
                                                  error:(NSError**)error;

/**
 * Factory method for producing <code>BCMIncidentUpdate</code> entity to use with <code>createIncidentUpdate</code>.
 * @param incident Associated incident.
 * @return New <code>BCMIncidentUpdate</code> object.
 */
- (BCMIncidentUpdate*)incidentUpdateForIncident:(BCMIncident*)incident;

@end
