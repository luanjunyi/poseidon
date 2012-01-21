//
//  BCMConveneRoom.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMContact, BCMIncident;

@interface BCMConveneRoom : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cmtContacts;
@property (nonatomic, retain) NSSet *inverseIncidents;
@end

@interface BCMConveneRoom (CoreDataGeneratedAccessors)

- (void)addCmtContactsObject:(BCMContact *)value;
- (void)removeCmtContactsObject:(BCMContact *)value;
- (void)addCmtContacts:(NSSet *)values;
- (void)removeCmtContacts:(NSSet *)values;
- (void)addInverseIncidentsObject:(BCMIncident *)value;
- (void)removeInverseIncidentsObject:(BCMIncident *)value;
- (void)addInverseIncidents:(NSSet *)values;
- (void)removeInverseIncidents:(NSSet *)values;
@end
