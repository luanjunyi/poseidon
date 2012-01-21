//
//  NSManagedObjectContext+Utility.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BCMPagedResult;

/**
 * Category providing helper methods for <code>NSManagedObjectContext</code>.
 * @author proxi
 * @version 1.0
 */
@interface NSManagedObjectContext(Utility)

/**
 * Deletes all managed objects of given entity.
 * @param entityName Name of the entity.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)deleteAllObjectsForEntityName:(NSString*)entityName error:(NSError**)error;

/**
 * Fetches objects of given entity, using given fetch offset and batch size.
 * @param entityName Entity name.
 * @param predicate Fetch predicate.
 * @param fetchOffset Fetch offset.
 * @param fetchBatchSize Fetch batch size or <code>0</code> to fetch all records.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> or <code>nil</code> if error occured.
 */
- (BCMPagedResult*)fetchObjectsForEntityName:(NSString*)entityName
                               withPredicate:(NSPredicate*)predicate
                                    atOffset:(NSUInteger)fetchOffset
                               withBatchSize:(NSUInteger)fetchBatchSize
                                       error:(NSError**)error;

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
                              error:(NSError**)error;

/**
 * Fetches object of given entity for specified ID.
 * @param entityName Entity name.
 * @param entityId the entity ID
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>NSManagedObject</code> or <code>nil</code> if not found or error occured.
 */
- (NSManagedObject*)getObjectForEntityName:(NSString*)entityName
                                    withId:(NSNumber*)entityId
                                     error:(NSError**)error;
@end
