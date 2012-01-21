//
//  NSManagedObject+JSON.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 * Category that extends <code>NSManagedObject</code> with methods to serialize
 * to and from JSON dictionaries.
 * @author proxi
 * @version 1.1
 */
@interface NSManagedObject(JSON)

/**
 * This method will take an NSDictionary (which may have nested NSArray or NSDictionary
 * values) that can represent a JSON structure, to populate all its field values.
 * At the beginning it will clear all its current field values.
 * This method is useful for the services that use SBJSON to parse the REST API returned
 * data to NSArray/NSDictionary representing values.
 * @param data JSON structure to parse.
 */
- (void)fromJSON:(NSDictionary*)data;

/**
 * This method is a reverse operation of the <code>fromJSON</code>.
 * It is useful for the services that use SBJON to write NSArray/NSDictionary values to JSON String to be posted to REST API.
 * @return <code>NSDictionary</code> representing JSON serialization of the object.
 */
- (NSDictionary*)toJSON;

/**
 * Returns entity of given class name, populating its fields from provided <code>NSDictionary</code>.
 * @param entityName Entity class name.
 * @param managedObjectContext <code>NSManagedObjectContext</code> to use.
 * @param data JSON dictionary to populate entity fields from.
 * @return Entity of requested class loaded from provided <code>NSDictionary</code>.
 */
+ (NSManagedObject*)objectForEntityForName:(NSString*)entityName
                    inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                                  fromJSON:(NSDictionary*)data;

@end
