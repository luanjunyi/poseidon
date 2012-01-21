//
//  NSManagedObject+JSON.m
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "NSManagedObject+JSON.h"

#import "NSDate+JSON.h"

/**
 * JSON key used as index.
 */
static NSString* const kJsonIdKey = @"Id";

/**
 * Attribute userInfo key used to override target JSON key.
 */
static NSString* const kBCMJsonKeyKey = @"bcmJsonKey";

/**
 * Relationship userInfo key used to disable JSON serialization.
 */
static NSString* const kBCMJsonDisableWriteKey = @"bcmJsonDisableWrite";

@implementation NSManagedObject(JSON)

/**
 * Returns key to use for JSON serialization of a property.
 * Defaults to property name with first letter capitalized.
 * Can be overriden by setting <code>bcmJsonKey</code> userInfo
 * entry on a property in CoreData model.
 * @param propertyName Property name.
 * @return Key to use for JSON serialization of the property.
 */
- (NSString*)getJsonKeyForProperty:(NSString*)propertyName {
    NSAttributeDescription* attributeDescription = (NSAttributeDescription *)[[[self entity] propertiesByName] objectForKey:propertyName];
    NSString* jsonKey = (NSString*)([[attributeDescription userInfo] objectForKey:kBCMJsonKeyKey]);
    if (jsonKey != nil) {
        return jsonKey;
    }

    NSString* firstUppercaseChar = [[propertyName substringToIndex:1] uppercaseString];
    NSString* newKey = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstUppercaseChar];
    return newKey;
}

/**
 * Returns entity of given class name, populating its fields from provided <code>NSDictionary</code>.
 * @param entityName Entity class name.
 * @param managedObjectContext <code>NSManagedObjectContext</code> to use.
 * @param data JSON dictionary to populate entity fields from.
 * @return Entity of requested class loaded from provided <code>NSDictionary</code>.
 */
+ (NSManagedObject*)objectForEntityForName:(NSString*)entityName
                    inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                                  fromJSON:(NSDictionary*)data {
    NSManagedObject* entity = nil;

    NSObject* objectId = [data objectForKey:kJsonIdKey];
    if (objectId) {
        // Fetch object with given id.
        NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
        request.predicate = [NSPredicate predicateWithFormat:@"id == %@", objectId];
        NSArray* result = [managedObjectContext executeFetchRequest:request error:nil];
        if ([result count] > 0) {
            entity = [result objectAtIndex:0];
        }
    }

    if (!entity) {
        entity = (NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                 inManagedObjectContext:managedObjectContext];
    }

    [entity fromJSON:data];

    return entity;
}

/**
 * This method will take an NSDictionary (which may have nested NSArray or NSDictionary
 * values) that can represent a JSON structure, to populate all its field values.
 * At the beginning it will clear all its current field values.
 * This method is useful for the services that use SBJSON to parse the REST API returned
 * data to NSArray/NSDictionary representing values.
 * @param data JSON structure to parse.
 */
- (void)fromJSON:(NSDictionary*)data {
    NSDictionary* properties = [[self entity] propertiesByName];
    NSDictionary* relationships = [[self entity] relationshipsByName];

    NSArray* keys = [properties allKeys];

    for (NSUInteger i = 0; i < [keys count]; i++) {
        NSString* propertyName = (NSString*)[keys objectAtIndex:i];
        NSString* key = [self getJsonKeyForProperty:propertyName];
        if (key == nil) {
            // This property is not serializable to JSON.
            continue;
        }

        // Clear current value, as per requirements. Do not clear inverse relationships.
        if (![propertyName hasPrefix:@"inverse"]) {
            [self setValue:nil forKey:propertyName];
        }

        id value = [data objectForKey:key];
        if (value == nil) {
            // No JSON data available for this property.
            continue;
        }

        NSRelationshipDescription* relationship = [relationships objectForKey:propertyName];

        if ([value isKindOfClass:[NSNull class]]) {
            // null value, do nothing (field was already cleared).
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // JSON dictionaries are converted to entities.
            if (relationship) {
                NSString* destinationClassName = [[relationship destinationEntity] managedObjectClassName];

                NSManagedObject* convertedObject = [[self class] objectForEntityForName:destinationClassName
                                                                 inManagedObjectContext:[self managedObjectContext]
                                                                               fromJSON:value];
                [self setValue:convertedObject forKey:propertyName];
            }
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            // JSON arrays are converted to NSSets of entities.
            if (relationship) {
                NSString* destinationClassName = [[relationship destinationEntity] managedObjectClassName];
                NSArray* values = (NSArray*)value;

                NSMutableArray* convertedValues = [NSMutableArray array];
                for (NSDictionary* object in values) {
                    NSManagedObject* convertedObject = [[self class] objectForEntityForName:destinationClassName
                                                                     inManagedObjectContext:[self managedObjectContext]
                                                                                   fromJSON:object];
                    [convertedValues addObject:convertedObject];
                }
                
                [self setValue:[NSSet setWithArray:convertedValues] forKey:propertyName];
            }
        } else {
            NSAttributeDescription* attributeDescription = (NSAttributeDescription *)[[[self entity] propertiesByName] objectForKey:propertyName];
            // NSDate attribute.
            if ([attributeDescription attributeType] == NSDateAttributeType) {
                if ([value isKindOfClass:[NSDate class]]) {
                    [self setValue:value forKey:propertyName];
                } else {
                    [self setValue:[NSDate dateFromJSON:value] forKey:propertyName];
                }
            } else {
                [self setValue:value forKey:propertyName];
            }
        }
    }
}

/**
 * This method is a reverse operation of the <code>fromJSON</code>.
 * It is useful for the services that use SBJON to write NSArray/NSDictionary values to JSON String to be posted to REST API.
 * @return <code>NSDictionary</code> representing JSON serialization of the object.
 */
- (NSDictionary*)toJSON {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    NSDictionary* properties = [[self entity] propertiesByName];
    NSArray* keys = [properties allKeys];
    
    for (NSUInteger i = 0; i < [keys count]; i++) {
        NSString* propertyName = (NSString*)[keys objectAtIndex:i];
        NSString* key = [self getJsonKeyForProperty:propertyName];
        if (key == nil) {
            // This property is not serializable to JSON.
            continue;
        }

        id value = [self valueForKey:propertyName];
        
        NSPropertyDescription* propertyDescription = (NSPropertyDescription *)[[[self entity] propertiesByName] objectForKey:propertyName];
        BOOL disableWrite = [[[propertyDescription userInfo] objectForKey:kBCMJsonDisableWriteKey] boolValue];
        if (disableWrite) {
            continue;
        }

        // NSDate attribute.
        if ([value isKindOfClass:[NSDate class]]) {
            [result setValue:[NSDate jsonStringFromDate:value] forKey:key];
        } else if ([value isKindOfClass:[NSManagedObject class]]) {
            [result setValue:[value toJSON] forKey:key];
        } else if ([value isKindOfClass:[NSSet class]]) {
            NSMutableArray* children = [NSMutableArray array];
            for (NSManagedObject* child in value) {
                [children addObject:[child toJSON]];
            }
            [result setValue:children forKey:key];
        } else {
            [result setValue:value forKey:key];
        }
    }

    return result;
}

@end
