//
//  BCMUtilityService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUtilityService.h"

#import "BCMSEntities.h"
#import "NSManagedObjectContext+Utility.h"

#import "BCMUserService.h"

@implementation BCMUtilityService

/**
 * Clears all the local entities, including the BCMRefreshLog.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)clearLocalData:(NSError**)error {
    if (error) {
        *error = nil;
    }

    NSArray* entityNames = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities valueForKey:@"name"];
    for (NSString* entityName in entityNames) {
        NSError* deleteError = nil;
        if (![self.managedObjectContext deleteAllObjectsForEntityName:entityName error:&deleteError]) {
            if (error) {
                *error = deleteError;
            }

            return NO;
        }
    }

    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMUtilityService(clearLocalData:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        return NO;
    }

    return YES;
}

/** Queries the BCMRefreshLog to find last refresh time of the given entity name.
 * @param entityName Name of the entity to query for.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Time of the last refresh of the entity or <code>nil</code> if no refresh is recorded or error occured.
 */
- (NSDate*)getLastRefreshTimeFor:(NSString*)entityName error:(NSError**)error {
    if (error) {
        *error = nil;
    }

    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:@"BCMRefreshLog" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bcmEntityName == %@", entityName];

    NSError* fetchError = nil;
    NSArray* items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if ([items count] == 0) {
        if (error) {
            *error = fetchError;
        }

        return nil;
    }

    BCMRefreshLog* refreshLog = (BCMRefreshLog*)[items objectAtIndex:0];
    return refreshLog.lastRefreshTime;
}

/** Update the BCMRefreshLog to set last refresh time of the given entity name. The current time will be used.
 * @param entityName Name of the entity to set last refresh time for.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)setLastRefreshTimeFor:(NSString*)entityName error:(NSError**)error {
    NSDate* now = [NSDate date];

    if (error) {
        *error = nil;
    }

    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:@"BCMRefreshLog" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bcmEntityName == %@", entityName];

    NSError* fetchError = nil;
    BCMRefreshLog* refreshLog = nil;

    NSArray* items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if ([items count] == 0) {
        if (fetchError) {
            if (error) {
                *error = fetchError;
            }

            return NO;
        }
        
        refreshLog = (BCMRefreshLog*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMRefreshLog"
                                                                   inManagedObjectContext:self.managedObjectContext];
        refreshLog.bcmEntityName = entityName;
    } else {
        refreshLog = (BCMRefreshLog*)[items objectAtIndex:0];
    }

    refreshLog.lastRefreshTime = now;

    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMUtilityService(setLastRefreshTimeFor:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        return NO;
    }
    
    return YES;
}

@end
