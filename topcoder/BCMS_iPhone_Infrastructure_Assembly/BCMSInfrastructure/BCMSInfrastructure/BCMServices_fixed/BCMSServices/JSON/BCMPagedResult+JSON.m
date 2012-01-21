//
//  BCMPagedResult+JSON.m
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMPagedResult+JSON.h"

#import "NSManagedObject+JSON.h"

@implementation BCMPagedResult(JSON)

/**
 * Parses complete service response JSON into BCMPagedResult.
 * @param entityName Result entity name.
 * @param managedObjectContext <code>NSManagedObjectContext</code> to use.
 * @param data JSON dictionary to parse.
 * @return Parsed <code>BCMPagedResult</code>.
 */
+ (BCMPagedResult*)pagedResultForEntityName:(NSString*)entityName
                     inManagedObjectContext:(NSManagedObjectContext*) managedObjectContext
                                   fromJSON:(NSDictionary*)result {
    BCMPagedResult* pagedResult = [[[BCMPagedResult alloc] init] autorelease];
    pagedResult.startCount = [[result objectForKey:@"StartCount"] integerValue];
    pagedResult.pageSize = [[result objectForKey:@"PageSize"] integerValue];
    pagedResult.totalCount = [[result objectForKey:@"TotalCount"] integerValue];

    NSArray* resultValues = [result objectForKey:@"Results"];
    
    NSMutableArray* entities = [NSMutableArray array];
    for (NSDictionary* value in resultValues) {
        NSManagedObject* entity = [NSManagedObject objectForEntityForName:entityName
                                                   inManagedObjectContext:managedObjectContext
                                                                 fromJSON:value];
        [entities addObject:entity];
    }
    pagedResult.values = entities;
    
    return pagedResult;
}

@end
