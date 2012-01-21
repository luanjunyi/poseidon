//
//  BCMIncidentAssociationService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c)2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMIncidentAssociation;

/**
 * Service responsible for managing <code>BCMIncidentAssociation</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentAssociationService : BCMSService

/** Gets <code>BCMIncidentAssociation</code>s from the local persistence, with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getIncidentAssociationsWith:(NSString*)token
                                  atStartCount:(NSUInteger)startCount
                                   andPageSize:(NSUInteger)pageSize
                                         error:(NSError**)error;

/**
 * Creates new incident association.
 * @param incidentAssociation Incident association.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentAssociation:(BCMIncidentAssociation*)incidentAssociation
                             withToken:(NSString*)token
                                 error:(NSError**)error;

/**
 * Removes incident association between specified primary and secondary incidents
 * @param primaryIncidentId the ID of primary incident
 * @param secondaryIncidentId the ID of secondary incident
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentAssociation:(NSNumber*)primaryIncidentId
                    withSecondary: (NSNumber*)secondaryIncidentId
                        withToken:(NSString*)token
                            error:(NSError**)error;

/**
 * Adds new incident association between specified primary and secondary incidents
 * @param primaryIncidentId the ID of primary incident
 * @param secondaryIncidentId the ID of secondary incident
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)addIncidentAssociation:(NSNumber*)primaryIncidentId 
                 withSecondary: (NSNumber*)secondaryIncidentId
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
 * Factory method for producing <code>BCMIncidentAssociation</code> entity to use with <code>createIncidentAssociation</code>.
 * @return New <code>BCMIncidentAssociation</code> object.
 */
- (BCMIncidentAssociation*)incidentAssociation;

@end
