//
//  BCMIncidentCategory.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMContact, BCMIncident;

@interface BCMIncidentCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *inverseIncidents;
@property (nonatomic, retain) NSSet *ismContacts;
@end

@interface BCMIncidentCategory (CoreDataGeneratedAccessors)

- (void)addInverseIncidentsObject:(BCMIncident *)value;
- (void)removeInverseIncidentsObject:(BCMIncident *)value;
- (void)addInverseIncidents:(NSSet *)values;
- (void)removeInverseIncidents:(NSSet *)values;
- (void)addIsmContactsObject:(BCMContact *)value;
- (void)removeIsmContactsObject:(BCMContact *)value;
- (void)addIsmContacts:(NSSet *)values;
- (void)removeIsmContacts:(NSSet *)values;
@end
