//
//  BCMIncidentNoteService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentNoteService.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentNote.h"
#import "BCMIncident.h"

@implementation BCMIncidentNoteService

/**
 * Returns all the <code>BCMIncidentNote</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch notes for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentNote</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentNotesForIncident:(NSNumber*)incidentId
                            withToken:(NSString*)token
                                error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"incidentId == %@", incidentId];
    
    NSArray* result = [self.managedObjectContext getObjectsForEntityName:@"BCMIncidentNote"
                                                           withPredicate:predicate
                                                         sortDescriptors:nil
                                                                   error:error];

    if (!result) {
        return nil;
    }
    
    return [NSSet setWithArray:result];
}

/**
 * Creates new incident note.
 * @param incidentNote Incident note.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentNote:(BCMIncidentNote*)incidentNote
                      withToken:(NSString*)token
                          error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:incidentNote
                          URI:[NSString stringWithFormat:@"incidentNotes"]
                        token:token
                        error:error];
    incidentNote.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes incident note.
 * @param incidentNoteId Incident note id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentNote:(NSNumber*)incidentNoteId
                 withToken:(NSString*)token
                     error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:incidentNoteId
                                URI:[NSString stringWithFormat:@"incidentNotes/%@", incidentNoteId]
                      forEntityName:@"BCMIncidentNote"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates incident note.
 * @param incidentNote Incident note.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncidentNote:(BCMIncidentNote*)incidentNote
                 withToken:(NSString*)token
                     error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:incidentNote
                          URI:[NSString stringWithFormat:@"incidentNotes/%@", incidentNote.id]
                   withParent:nil
                        token:token
                        error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Factory method for producing <code>BCMIncidentNote</code> entity to use with <code>createIncidentNote</code>.
 * @param incident Associated incident.
 * @return New <code>BCMIncidentNote</code> object.
 */
- (BCMIncidentNote*)incidentNoteForIncident:(BCMIncident*)incident {
    BCMIncidentNote* incidentNote = (BCMIncidentNote*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentNote"
                                                                                    inManagedObjectContext:self.managedObjectContext];
    incidentNote.incidentId = incident.id;
    return incidentNote;
}

@end
