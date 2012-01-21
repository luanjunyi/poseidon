//
//  NSManagedObjectContext+Utility.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "NSManagedObjectContext+Utility.h"

#import "BCMPagedResult.h"

@implementation NSManagedObjectContext(Utility)

/**
 * Deletes all managed objects of given entity.
 * @param entityName Name of the entity.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)deleteAllObjectsForEntityName:(NSString*)entityName error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    
    NSArray* items = [self executeFetchRequest:fetchRequest error:error];
    if (items == nil) {
        return NO;
    }
    
    for (NSManagedObject* managedObject in items) {
        [self deleteObject:managedObject];
    }
    
    return YES;
}

/**
 * Fetches objects of given entity, using given fetch offset and batch size.
 * @param entityName Entity name.
 * @param predicate Fetch predicate for filtering.
 * @param fetchOffset Fetch offset.
 * @param fetchBatchSize Fetch batch size or <code>0</code> to fetch all records.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> or <code>nil</code> if error occured.
 */
- (BCMPagedResult*)fetchObjectsForEntityName:(NSString*)entityName
                               withPredicate:(NSPredicate*)predicate
                                    atOffset:(NSUInteger)fetchOffset
                               withBatchSize:(NSUInteger)fetchBatchSize
                                       error:(NSError**)error {
    if (error) {
        *error = nil;
    }

    BCMPagedResult* result = [[[BCMPagedResult alloc] init] autorelease];
    result.startCount = fetchOffset;
    result.pageSize = fetchBatchSize;

    NSError* fetchError = nil;
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    // set predicate here so it will be returned total count after filtering
    // which means that total count will show actual count of entities which can be acquired
    // with specified filter or without it if predicate is nil
    if(predicate != nil){
        fetchRequest.predicate = predicate;
    }
    
    result.totalCount = [self countForFetchRequest:fetchRequest error:&fetchError];
    if (result.totalCount == NSNotFound) {
        if (error) {
            *error = fetchError;
        }
        
        return nil;
    }

    // setup request bounds
    fetchRequest.fetchOffset = fetchOffset;
    fetchRequest.fetchBatchSize = fetchBatchSize;
    fetchRequest.fetchLimit = fetchBatchSize;
    
    // do actual data fetch if appropriate
    if(fetchOffset < result.totalCount){
        // fetch data and set values only if specified fetch offset is lower than actual total count of results
        NSArray* items = [self executeFetchRequest:fetchRequest error:&fetchError];
        if (items == nil) {
            if (error) {
                *error = fetchError;
            }
            // error occurs - return NIL
            return nil;
        }
        result.values = items;
    }else{
        // just set empty array to avoid errors
        result.values = [NSArray array];
    }
    
    return result;
}

/**
 * Fetches objects of given entity, using given predicate.
 * @param entityName Entity name.
 * @param predicate Fetch predicate.
 * @param sortDescriptors Sort descriptors.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSArray</code> or <code>nil</code> if error occured.
 */
- (NSArray*)getObjectsForEntityName:(NSString*)entityName
                      withPredicate:(NSPredicate*)predicate
                    sortDescriptors:(NSArray*)sortDescriptors
                              error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSError* fetchError = nil;
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;

    NSArray* items = [self executeFetchRequest:fetchRequest error:&fetchError];
    if (items == nil) {
        if (error) {
            *error = fetchError;
        }
        
        return nil;
    }
    
    return items;
}

/**
 * Fetches object of given entity for specified ID.
 * @param entityName Entity name.
 * @param entityId the entity ID
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSManagedObject</code> or <code>nil</code> if not found or error occured.
 */
- (NSManagedObject*)getObjectForEntityName:(NSString*)entityName
                                    withId:(NSNumber*)entityId
                                     error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %@", entityId];
    
    NSError* fetchError = nil;
    NSArray* items = [self executeFetchRequest:fetchRequest error:&fetchError];
    if ([items count] == 0) {
        if (error) {
            *error = fetchError;
        }
        
        return nil;
    }else{
        return [items lastObject];
    }
}

@end
