//
//  BCMIncidentUpdateService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentUpdateService.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncidentUpdate.h"
#import "BCMIncident.h"

@implementation BCMIncidentUpdateService

/**
 * Returns all the <code>BCMIncidentUpdate</code>s associated with the given incident. 
 * @param incidentId Id of <code>BCMIncident</code> to fetch updates for.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSSet</code> of associated <code>BCMIncidentUpdate</code>s, or <code>nil</code> if error occured.
 */
- (NSSet*)getIncidentUpdatesForIncident:(NSNumber*)incidentId
                              withToken:(NSString*)token
                                  error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"incidentId == %@", incidentId];
    
    NSArray* result = [self.managedObjectContext getObjectsForEntityName:@"BCMIncidentUpdate"
                                                           withPredicate:predicate
                                                         sortDescriptors:nil
                                                                   error:error];

    if (!result) {
        return nil;
    }
    
    return [NSSet setWithArray:result];
}

/**
 * Creates new incident update.
 * @param incidentUpdate Incident update.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentUpdate:(BCMIncidentUpdate*)incidentUpdate
                        withToken:(NSString*)token
                            error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:incidentUpdate
                                      URI:[NSString stringWithFormat:@"incidentUpdates"]
                                    token:token
                                    error:error];
    incidentUpdate.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes incident update.
 * @param incidentUpdateId Incident update id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncidentUpdate:(NSNumber*)incidentUpdateId
                   withToken:(NSString*)token
                       error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:incidentUpdateId
                                    URI:[NSString stringWithFormat:@"incidentUpdates/%@", incidentUpdateId]
                          forEntityName:@"BCMIncidentUpdate"
                                  token:token
                                  error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates incident update.
 * @param incidentUpdate Incident update.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncidentUpdate:(BCMIncidentUpdate*)incidentUpdate
                   withToken:(NSString*)token
                       error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:incidentUpdate
                              URI:[NSString stringWithFormat:@"incidentUpdates/%@", incidentUpdate.id]
                       withParent:nil
                            token:token
                            error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

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
                       error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    BOOL res = YES;
    // made it transactionaly
    [self.managedObjectContext lock];

    NSArray* updates = [self.managedObjectContext getObjectsForEntityName:@"BCMIncidentUpdate"
                                                            withPredicate:[NSPredicate predicateWithFormat:@"id == %@", incidentUpdateId]
                                                          sortDescriptors:nil
                                                                    error:error];
    if ([updates count] == 0) {
        BCMServicesLog(@"BCMSIncidentUpdateService(resendIncidentUpdate:toGroups:withToken:error:): No such incident %@", incidentUpdateId);
        res = NO;
    }else{        
        BCMIncidentUpdate* incidentUpdate = (BCMIncidentUpdate*)[updates objectAtIndex:0];
        
        // Serialize data.
        NSError* serializationError = nil;
        NSData* groupsData = [self serializeObject:groups error:&serializationError];
        if (!groupsData) {
            if (error) {
                *error = serializationError;
            }
            res = NO;
        }else{
            // Post serialized object to server.
            NSError* remoteError = nil;
            NSNumber* result = [self remote:@"POST"
                                       path:[NSString stringWithFormat:@"%@/incidentUpdates/resend/%@", token, incidentUpdateId]
                                       data:groupsData
                                      error:&remoteError];
            if (![result boolValue]) {
                if (error) {
                    *error = remoteError;
                }
                res = NO;
            }else{
                incidentUpdate.alertSent = [NSNumber numberWithBool:YES];
                
                // Commit store.
                NSError* saveError = nil;
                if (![self.managedObjectContext save:&saveError]) {
                    BCMServicesLog(@"BCMSIncidentUpdateService(resendIncidentUpdate:toGroups:withToken:error:): Error saving %@", saveError);
                    if (error) {
                        *error = saveError;
                    }
                    res = NO;
                }
            }
        }
    }
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Returns lates incident update of given incident.
 * @param incidentId Incident id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Latest incident update or <code>nil</code>.
 */
- (BCMIncidentUpdate*)getLatestIncidentUpdateOfIncident:(NSNumber*)incidentId
                                              withToken:(NSString*)token
                                                  error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"incidentId == %@", incidentId];

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];

    NSArray* result = [self.managedObjectContext getObjectsForEntityName:@"BCMIncidentUpdate"
                                                           withPredicate:predicate
                                                         sortDescriptors:sortDescriptors
                                                                   error:error];
    
    if ([result count] == 0) {
        return nil;
    }

    BCMIncidentUpdate* incidentUpdate = (BCMIncidentUpdate*)[result objectAtIndex:0];
    return incidentUpdate;
}

/**
 * Factory method for producing <code>BCMIncidentUpdate</code> entity to use with <code>createIncidentUpdate</code>.
 * @param incident Associated incident.
 * @return New <code>BCMIncidentUpdate</code> object.
 */
- (BCMIncidentUpdate*)incidentUpdateForIncident:(BCMIncident*)incident {
    BCMIncidentUpdate* incidentUpdate = (BCMIncidentUpdate*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentUpdate"
                                                                                          inManagedObjectContext:self.managedObjectContext];
    incidentUpdate.incidentId = incident.id;
    return incidentUpdate;
}

@end
