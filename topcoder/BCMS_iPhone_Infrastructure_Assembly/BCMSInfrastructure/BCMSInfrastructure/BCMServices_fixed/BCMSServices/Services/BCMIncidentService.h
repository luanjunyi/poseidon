//
//  BCMIncidentService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMIncident;
@class BCMIncidentFilter;

/**
 * Service responsible for managing <code>BCMIncident</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentService : BCMSService

/** Gets <code>BCMIncident</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getIncidentsWith:(NSString*)token
                       atStartCount:(NSUInteger)startCount
                        andPageSize:(NSUInteger)pageSize
                              error:(NSError**)error;

/** Gets <code>BCMIncident</code>s from the local persistence, using given filter, with given fetch size and fetch offset,
 * @param token Authentication token.
 * @param filter Search filter.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)searchIncidentsWith:(NSString*)token
                             forFilter:(BCMIncidentFilter*)filter
                          atStartCount:(NSUInteger)startCount
                           andPageSize:(NSUInteger)pageSize
                                 error:(NSError**)error;

/** Gets <code>BCMIncident</code> given its id.
 * @param incidentId Id of <code>BCMIncident</code> to fetch.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMIncident</code> if incident with given id is found, otherwise <code>nil</code>.
 */
- (BCMIncident*)getIncidentFor:(NSNumber*)incidentId
                     withToken:(NSString*)token
                         error:(NSError**)error;

/**
 * Creates new incident.
 * @param incident Incident.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncident:(BCMIncident*)incident
                  withToken:(NSString*)token
                      error:(NSError**)error;

/**
 * Deletes incident.
 * @param incidentId Incident id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncident:(NSNumber*)incidentId
             withToken:(NSString*)token
                 error:(NSError**)error;

/**
 * Updates incident.
 * @param incident Incident.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncident:(BCMIncident*)incident
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
 * Factory method for producing <code>BCMIncident</code> entity to use with <code>createIncident</code>.
 * @return New <code>BCMIncident</code> object.
 */
- (BCMIncident*)incident;

@end
