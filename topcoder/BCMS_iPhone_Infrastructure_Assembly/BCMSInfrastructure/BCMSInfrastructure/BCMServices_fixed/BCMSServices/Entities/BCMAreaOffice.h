//
//  BCMAreaOffice.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMContact, BCMIncident;

@interface BCMAreaOffice : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *inverseIncidents;
@end

@interface BCMAreaOffice (CoreDataGeneratedAccessors)

- (void)addContactsObject:(BCMContact *)value;
- (void)removeContactsObject:(BCMContact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;
- (void)addInverseIncidentsObject:(BCMIncident *)value;
- (void)removeInverseIncidentsObject:(BCMIncident *)value;
- (void)addInverseIncidents:(NSSet *)values;
- (void)removeInverseIncidents:(NSSet *)values;
@end
