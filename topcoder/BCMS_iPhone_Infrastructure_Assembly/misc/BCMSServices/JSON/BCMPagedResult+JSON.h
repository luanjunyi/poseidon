//
//  BCMPagedResult+JSON.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMPagedResult.h"

@class NSManagedObjectContext;

/**
 * Category that extends <code>BCMPagedResult</code> with method to parse
 * JSON data from service response.
 * @author proxi
 * @version 1.1
 */
@interface BCMPagedResult(JSON)

/**
 * Parses complete service response JSON into BCMPagedResult.
 * @param entityName Result entity name.
 * @param managedObjectContext <code>NSManagedObjectContext</code> to use.
 * @param data JSON dictionary to parse.
 * @return Parsed <code>BCMPagedResult</code>.
 */
+ (BCMPagedResult*)pagedResultForEntityName:(NSString*)entityName
                     inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                                   fromJSON:(NSDictionary*)data;

@end
