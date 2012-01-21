//
//  BCMIncidentAttachmentService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentAttachmentService.h"

#import "NSManagedObjectContext+Utility.h"
#import "NSManagedObject+JSON.h"

@implementation BCMIncidentAttachmentService

/**
 * Returns all the <code>BCMIncidentAttachments</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch attachments for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentAttachments</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentAttachmentsForIncident:(NSNumber*)incidentId
                                  withToken:(NSString*)token
                                      error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"incidentId == %@", incidentId];

    NSArray* result = [self.managedObjectContext getObjectsForEntityName:@"BCMIncidentAttachment"
                                                           withPredicate:predicate
                                                         sortDescriptors:nil
                                                                   error:error];
    
    if (!result) {
        return nil;
    }
    
    return [NSSet setWithArray:result];
}

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
                                             error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // made it transactionaly
    [self.managedObjectContext lock];
    
    // Upload data to server.
    NSError* remoteError = nil;
    NSDictionary* result = [self upload:content
                                   path:[NSString stringWithFormat:@"%@/incidentAttachments?incidentId=%@&filename=%@", token, incidentId, fileName]
                                  error:&remoteError];
    BCMIncidentAttachment* incidentAttachment = nil;
    if (!result) {
        if (error) {
            *error = remoteError;
        }
    }else{
        BCMServicesLog(@"BCMSIncidentAttachmentService(uploadIncidentAttachment:andData:forIncident:withToken:error:): Response %@", result);
        
        incidentAttachment = (BCMIncidentAttachment*)[NSManagedObject objectForEntityForName:@"BCMIncidentAttachment"
                                                                      inManagedObjectContext:self.managedObjectContext
                                                                                    fromJSON:result];
        
        // Commit store.
        NSError* saveError = nil;
        if (![self.managedObjectContext save:&saveError]) {
            BCMServicesLog(@"BCMSIncidentAttachmentService(uploadIncidentAttachment:andData:forIncident:withToken:error:): Error saving %@", saveError);
            if (error) {
                *error = saveError;
            }
            incidentAttachment = nil;
        }
    }
    [self.managedObjectContext unlock];
    
    return incidentAttachment;
}

/**
 * Deletes incident attachment.
 * @param incidentAttachmentId Incident attachment id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentAttachment:(NSNumber*)incidentAttachmentId
                       withToken:(NSString*)token
                           error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:incidentAttachmentId
                                URI:[NSString stringWithFormat:@"incidentAttachments/%@", incidentAttachmentId]
                      forEntityName:@"BCMIncidentAttachment"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Loads the data for attachment.
 * @param incidentAttachmentId Attachment id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded <code>NSData</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (NSData*)downloadIncidentAttachment:(NSNumber*)incidentAttachmentId 
                            withToken:(NSString*)token
                                error:(NSError**)error {
    return [self download:[NSString stringWithFormat:@"incidentAttachments/%@", incidentAttachmentId]
                    token:token
                    error:error];
}

@end
