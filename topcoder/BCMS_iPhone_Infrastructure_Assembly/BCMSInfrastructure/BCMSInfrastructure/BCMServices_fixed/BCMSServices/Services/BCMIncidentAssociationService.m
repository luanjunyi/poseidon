//
//  BCMIncidentAssociationService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentAssociationService.h"

#import "NSManagedObjectContext+Utility.h"
#import "NSManagedObject+JSON.h"
#import "BCMIncidentAssociation.h"
#import "BCMUtilityService.h"

@implementation BCMIncidentAssociationService

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
                                         error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMIncidentAssociation"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/**
 * Creates new incident association.
 * @param incidentAssociation Incident association.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncidentAssociation:(BCMIncidentAssociation*)incidentAssociation
                             withToken:(NSString*)token
                                 error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // made it transactionaly
    [self.managedObjectContext lock];

    NSNumber* result = nil;
    // Serialize object.
    NSError* serializationError = nil;
    NSData* objectData = [self serializeObject:incidentAssociation error:&serializationError];
    if (!objectData) {
        if (error) {
            *error = serializationError;
        }
        [self.managedObjectContext deleteObject:incidentAssociation];
    }else{
        
        BCMServicesLog(@"BCMIncidentAssociationService(createIncidentAssociation:::): Object to create %@", incidentAssociation);
        
        // Post serialized object to server.
        NSError* remoteError = nil;
        NSNumber* response = [self remote:@"POST"
                                     path:[NSString stringWithFormat:@"%@/incidentAssociations", token]
                                     data:objectData
                                    error:&remoteError];
        if (![response boolValue]) {
            if (error) {
                *error = remoteError;
            }
            [self.managedObjectContext deleteObject:incidentAssociation];
        }else{
            // save association locally
            result = [incidentAssociation.primaryIncidentReport id];
            incidentAssociation.id = result;
            
            // Commit store.
            NSError* saveError = nil;
            if (![self.managedObjectContext save:&saveError]) {
                BCMServicesLog(@"BCMIncidentAssociationService(createIncidentAssociation:::): Error saving %@", saveError);
                if (error) {
                    *error = saveError;
                }
                [self.managedObjectContext deleteObject:incidentAssociation];
                result =  nil;
            }
        }
    }
    [self.managedObjectContext unlock];
    
    return result;
}

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
                            error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    
    if (error) {
        *error = nil;
    }
    
    // try to delete from remote server
    NSError* remoteError = nil;
    NSString* path = [NSString stringWithFormat:@"incidentAssociations/%@/%@", primaryIncidentId, secondaryIncidentId];
    NSNumber* result = [self remote:@"DELETE"
                               path:[NSString stringWithFormat:@"%@/%@", token, path]
                               data:nil
                              error:&remoteError];
    BOOL res = [result boolValue];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
    }else{   
        // check if local object should be deleted
        NSError* fetchError = nil;
        BCMIncidentAssociation* association = (BCMIncidentAssociation*)[self.managedObjectContext getObjectForEntityName:@"BCMIncidentAssociation" 
                                                                                                                  withId:primaryIncidentId 
                                                                                                                   error:&fetchError];
        if (association == nil) {
            // local association not found
            if (error) {
                *error = fetchError;
            }
            res = NO;
        }else{
            // check if local association should be removed
            BCMIncident* secIncident = (BCMIncident*)[self.managedObjectContext getObjectForEntityName:@"BCMIncident" 
                                                                                                withId:secondaryIncidentId 
                                                                                                 error:&fetchError];
            [association removeSecondaryIncidentReportsObject:secIncident];
            // check if secondary incidents left
            if([association.secondaryIncidentReports count] == 0){
                // looks like no associations left - removing
                [self.managedObjectContext deleteObject:association];
            }
            
            // Commit store.
            NSError* saveError = nil;
            if (![self.managedObjectContext save:&saveError]) {
                BCMServicesLog(@"BCMIncidentAssociationService(deleteIncidentAssociation::::): Error saving %@", saveError);
                if (error) {
                    *error = saveError;
                }
                res =  NO;
            }
        }
    }
    
    [self.managedObjectContext unlock];
    
    return res;
}

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
                         error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    
    if (error) {
        *error = nil;
    }
    
    // try to add association on remote server
    NSError* remoteError = nil;
    NSString* path = [NSString stringWithFormat:@"incidentAssociations/%@/%@", primaryIncidentId, secondaryIncidentId];
    NSNumber* result = [self remote:@"POST"
                               path:[NSString stringWithFormat:@"%@/%@", token, path]
                               data:nil
                              error:&remoteError];
    BOOL res = [result boolValue];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
    }else{
        // updating local store
        NSError* fetchError = nil;
        BCMIncidentAssociation* association = (BCMIncidentAssociation*)[self.managedObjectContext getObjectForEntityName:@"BCMIncidentAssociation" 
                                                                                                                  withId:primaryIncidentId 
                                                                                                                   error:&fetchError];
        if (association == nil) {
            // local association not found
            if (error) {
                *error = fetchError;
            }
            res = NO;
        }else{
            // add secondary incident to association
            BCMIncident* secIncident = (BCMIncident*)[self.managedObjectContext getObjectForEntityName:@"BCMIncident" 
                                                                                                withId:secondaryIncidentId 
                                                                                                 error:&fetchError];
            [association addSecondaryIncidentReportsObject:secIncident];
            // Commit store.
            NSError* saveError = nil;
            if (![self.managedObjectContext save:&saveError]) {
                BCMServicesLog(@"BCMIncidentAssociationService(addIncidentAssociation::::): Error saving %@", saveError);
                if (error) {
                    *error = saveError;
                }
                res =  NO;
            }
        }
    }
    
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Refresh all relevant entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Refresh entities from remote service
    //
    BCMUtilityService* utilityServ = [[[BCMUtilityService alloc]initWithContext:self.managedObjectContext andBaseURL:self.baseURL]autorelease];
    NSError* remoteError = nil;
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMIncidentAssociation" error:&remoteError];
    
    // adjust last refresh
    if(lastRefresh == nil){
        // set last refresh as reference time begin
        lastRefresh = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    }
    // format last refresh
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:BCM_JSON_DATE_FORMAT];
    NSString *formattedLastRefresh = [dateFormatter stringFromDate:lastRefresh];
    
    // Get total count of new entities on remote service
    //
    NSString* uriStr = [NSString stringWithFormat:@"%@&date=%@&startCount=1&pageSize=1", @"incidentAssociations?&sortBy=&sortAsc=true", formattedLastRefresh];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"CacheUpdatesService.svc/json/%@/updates/%@", token, uriStr] relativeToURL:self.baseURL];
    NSDictionary* result = [self remote:@"GET"
                                    URL:url
                                   data:nil
                            contentType:nil
                                  error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    NSNumber* totalCount = [result objectForKey:BCM_JSON_TOTAL_COUNT_KEY];
    if(totalCount == 0){
        // nothing to refresh, but it's not an error
        return YES;
    }
    
    // get all entities from remote endpoint
    //
    remoteError = nil;
    uriStr = [NSString stringWithFormat:@"%@&date=%@&startCount=1&pageSize=%i", @"incidentAssociations?&sortBy=&sortAsc=true", formattedLastRefresh, [totalCount intValue]];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"CacheUpdatesService.svc/json/%@/updates/%@", token, uriStr] relativeToURL:self.baseURL];
    result = [self remote:@"GET"
                      URL:url
                     data:nil
              contentType:nil
                    error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // Store entities localy
    //
    NSArray* resultList = [result objectForKey:BCM_JSON_REQUEST_RESULTS_COLLECTION_KEY];
    if(resultList.count > 0){
        // iterate over received users and store data
        [self.managedObjectContext lock];
        for(NSDictionary* json in resultList){
            // insert object into context
            BCMIncidentAssociation* association = (BCMIncidentAssociation*)[NSManagedObject objectForEntityForName:@"BCMIncidentAssociation" 
                                                                                            inManagedObjectContext:self.managedObjectContext 
                                                                                                          fromJSON:json];
            // set association ID as primary incident ID, because there is 
            // one-to-many association between primary and secondary incidents
            association.id = [association.primaryIncidentReport id];
        }
        [self.managedObjectContext unlock];
    }
    
    
    // set refresh log record
    remoteError = nil;
    BOOL res = [utilityServ setLastRefreshTimeFor:@"BCMIncidentAssociation" error:&remoteError];
    if(!res){
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // no errors detected
    return YES;
}

/**
 * Factory method for producing <code>BCMIncidentAssociation</code> entity to use with <code>createIncidentAssociation</code>.
 * @return New <code>BCMIncidentAssociation</code> object.
 */
- (BCMIncidentAssociation*)incidentAssociation {
    return (BCMIncidentAssociation*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentAssociation"
                                                                  inManagedObjectContext:self.managedObjectContext];
}

@end
