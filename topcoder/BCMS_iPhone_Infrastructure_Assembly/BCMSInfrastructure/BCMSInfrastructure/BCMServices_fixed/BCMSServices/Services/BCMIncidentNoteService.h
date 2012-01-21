//
//  BCMIncidentNoteService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMIncident;
@class BCMIncidentNote;

/**
 * Service responsible for managing <code>BCMIncidentNote</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentNoteService : BCMSService

/**
 * Returns all the <code>BCMIncidentNote</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch notes for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentNote</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentNotesForIncident:(NSNumber*)incidentId
                            withToken:(NSString*)token
                                error:(NSError**)error;

/**
 * Creates new incident note.
 * @param incidentNote Incident note.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentNote:(BCMIncidentNote*)incidentNote
                      withToken:(NSString*)token
                          error:(NSError**)error;

/**
 * Deletes incident note.
 * @param incidentNoteId Incident note id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentNote:(NSNumber*)incidentNoteId
                 withToken:(NSString*)token
                     error:(NSError**)error;

/**
 * Updates incident note.
 * @param incidentNote Incident note.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncidentNote:(BCMIncidentNote*)incidentNote
                 withToken:(NSString*)token
                     error:(NSError**)error;

/**
 * Factory method for producing <code>BCMIncidentNote</code> entity to use with <code>createIncidentNote</code>.
 * @param incident Associated incident.
 * @return New <code>BCMIncidentNote</code> object.
 */
- (BCMIncidentNote*)incidentNoteForIncident:(BCMIncident*)incident;

@end
