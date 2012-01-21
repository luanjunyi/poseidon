//
//  RoundTripTest.m
//  BCMSServicesTest
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "RoundTripTest.h"

#import "BCMSEntities.h"

@implementation RoundTripTest

/**
 * Recursively converts NSDictionary for roundtrip comparison.
 * - replaces NSArrays by NSSets (because we model one-to-many relationships as unordered NSSets)
 * - replaces JSON date strings with NSDates (to ignore timezone format part)
 * - drops NSNulls
 * - drops empty collections
 * @param data Dictionary to convert.
 * @return Converted dictionary.
 */
- (NSDictionary*)coerceForTestComparison:(NSDictionary*)data {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    for (NSString* key in [data allKeys]) {
        id value = [data objectForKey:key];
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            if ([value count] > 0) {
                NSMutableArray* children = [NSMutableArray array];
                for (NSDictionary* child in value) {
                    [children addObject:[self coerceForTestComparison:child]];
                }
                
                NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:TRUE];
                [children sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [sortDescriptor release];

                [result setValue:[NSSet setWithArray:children] forKey:key];
            }
        } else if ([value isKindOfClass:[NSString class]] && [(NSString*)value hasPrefix:@"/Date"]) {
            [result setValue:[NSDate dateFromJSON:value] forKey:key];
        } else if ([value isKindOfClass:[NSNull class]]) {
            // Drop.
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [result setValue:[self coerceForTestComparison:value] forKey:key];
        } else {
            [result setValue:value forKey:key];
        }
    }
    
    return result;
}

/**
 * Test that fromJSON -> toJSON preserves object structure.
 */
- (void)testRoundTrips {
    NSArray* entities = [NSArray arrayWithObjects:
                         @"BCMAdditionalInfo",
                         @"BCMAreaOffice",
                         @"BCMContact",
                         @"BCMContactRole",
                         @"BCMConveneRoom",
                         @"BCMHelpDocument",
                         @"BCMIncident",
                         @"BCMIncidentAssociation",
                         @"BCMIncidentAttachment",
                         @"BCMIncidentCategory",
                         @"BCMIncidentNote",
                         @"BCMIncidentStatus",
                         @"BCMIncidentType",
                         @"BCMIncidentUpdate",
                         @"BCMUser",
                         @"BCMUserGroup",
                         nil];

    for (NSString* entityName in entities) {
        NSDictionary* fixture = [self coerceForTestComparison:[self readFixture:[NSString stringWithFormat:@"%@.json", entityName]]];
        
        NSManagedObject* entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                    inManagedObjectContext:managedObjectContext];
        [entity fromJSON:fixture];
        
        NSDictionary* roundtrip = [self coerceForTestComparison:[entity toJSON]];
        
        STAssertEqualObjects(fixture, roundtrip, @"Invariant broken");
        
        [managedObjectContext deleteObject:entity];
    }
}

@end
