//
//  BCMIncidentService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentService.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMIncident.h"
#import "BCMIncidentFilter.h"
#import "BCMIncidentStatus.h"
#import "BCMUtilityService.h"

@implementation BCMIncidentService

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
                              error:(NSError**)error {
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMIncident"
                                                  withPredicate:nil
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

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
                                 error:(NSError**)error {
    NSMutableArray* subpredicates = [NSMutableArray array];
    if (filter.incidentNumber) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"incidentNumber == %@", filter.incidentNumber]];
    }
    if (filter.incident) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"incident == %@", filter.incident]];
    }
    if (filter.reportedDate) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"reportedDate == %@", filter.reportedDate]];
    }
    if (filter.ism) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"ism.name == %@", filter.ism]];
    }
    if (filter.location) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"location.name == %@", filter.location]];
    }
    if (filter.status) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"status.id == %@", filter.status.id]];
    }
    
    NSPredicate* predicate = [[[NSCompoundPredicate alloc] initWithType:NSCompoundPredicateTypeFromBCMFilterRule(filter.rule)
                                                  subpredicates:subpredicates] autorelease];
    
    return [self.managedObjectContext fetchObjectsForEntityName:@"BCMIncident"
                                                  withPredicate:predicate
                                                       atOffset:startCount
                                                  withBatchSize:pageSize
                                                          error:error];
}

/** Gets <code>BCMIncident</code> given its id.
 * @param incidentId Id of <code>BCMIncident</code> to fetch.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMIncident</code> if incident with given id is found, otherwise <code>nil</code>.
 */
- (BCMIncident*)getIncidentFor:(NSNumber*)incidentId
                     withToken:(NSString*)token
                         error:(NSError**)error {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@", incidentId];
    
    NSArray* result = [self.managedObjectContext getObjectsForEntityName:@"BCMIncident"
                                                           withPredicate:predicate
                                                         sortDescriptors:nil
                                                                   error:error];

    if ([result count] == 0) {
        return nil;
    }

    BCMIncident* incident = (BCMIncident*)[result objectAtIndex:0];
    return incident;
}

/**
 * Creates new incident.
 * @param incident Incident.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createIncident:(BCMIncident*)incident
                  withToken:(NSString*)token
                      error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    NSNumber* result = [self createObject:incident
                          URI:[NSString stringWithFormat:@"incidents"]
                        token:token
                        error:error];
    incident.id = result;
    [self.managedObjectContext unlock];
    
    return result;
}

/**
 * Deletes incident.
 * @param incidentId Incident id.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if successful, otherwise <code>NO</code>.
 */
- (BOOL)deleteIncident:(NSNumber*)incidentId
             withToken:(NSString*)token
                 error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self deleteObjectWithId:incidentId
                                URI:[NSString stringWithFormat:@"incidents/%@", incidentId]
                      forEntityName:@"BCMIncident"
                              token:token
                              error:error];
    [self.managedObjectContext unlock];
    
    return res;
}

/**
 * Updates incident.
 * @param incident Incident.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code>if successfull, otherwise <code>NO</code>.
 */
- (BOOL)updateIncident:(BCMIncident*)incident
             withToken:(NSString*)token
                 error:(NSError**)error {
    // made it transactionaly
    [self.managedObjectContext lock];
    BOOL res = [self updateObject:incident
                              URI:[NSString stringWithFormat:@"incidents/%@", incident.id]
                       withParent:nil
                            token:token
                            error:error];
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
    NSDate* lastRefresh = [utilityServ getLastRefreshTimeFor:@"BCMIncident" error:&remoteError];
    BOOL res = [self refreshPagedDataForEntity:@"BCMIncident" 
                                         since: lastRefresh 
                                           URI:@"incidents?" 
                                         token:token
                                         error:&remoteError];
    if (!res) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // set refresh log record
    remoteError = nil;
    res = [utilityServ setLastRefreshTimeFor:@"BCMIncident" error:&remoteError];
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
 * Factory method for producing <code>BCMIncident</code> entity to use with <code>createIncident</code>.
 * @return New <code>BCMIncident</code> object.
 */
- (BCMIncident*)incident {
    return (BCMIncident*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncident"
                                                       inManagedObjectContext:self.managedObjectContext];
}

@end
