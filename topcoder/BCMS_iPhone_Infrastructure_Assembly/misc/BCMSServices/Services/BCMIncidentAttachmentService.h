//
//  BCMIncidentAttachmentService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;
@class BCMIncidentAttachment;

/**
 * Service responsible for managing <code>BCMIncidentAttachment</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentAttachmentService : BCMSService

/**
 * Returns all the <code>BCMIncidentAttachments</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch attachments for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentAttachments</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentAttachmentsForIncident:(NSNumber*)incidentId
                                  withToken:(NSString*)token
                                      error:(NSError**)error;

/**
 * Uploads incident attachment.
 * @param fileName File name.
 * @param content Contents.
 * @param incidentId Id of the incident.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMIncidentAttachment</code> if successful, otherwise <code>nil</code>.
 */
- (BCMIncidentAttachment*)uploadIncidentAttachment:(NSString*)fileName
                                           andData:(NSData*)content
                                       forIncident:(NSNumber*)incidentId
                                         withToken:(NSString*)token
                                             error:(NSError**)error;

/**
 * Deletes incident attachment.
 * @param incidentAttachmentId Incident attachment id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentAttachment:(NSNumber*)incidentAttachmentId
                       withToken:(NSString*)token
                           error:(NSError**)error;

/**
 * Loads the data for attachment.
 * @param incidentAttachmentId Attachment id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded <code>NSData</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (NSData*)downloadIncidentAttachment:(NSNumber*)incidentAttachmentId 
                            withToken:(NSString*)token
                                error:(NSError**)error;

@end
