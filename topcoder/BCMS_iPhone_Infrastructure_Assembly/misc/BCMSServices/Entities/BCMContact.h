//
//  BCMContact.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMAreaOffice, BCMContactRole, BCMConveneRoom, BCMIncidentCategory, BCMUser;

@interface BCMContact : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * primaryNumber;
@property (nonatomic, retain) NSString * secondaryNumber;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSSet *inverseAreaOffices;
@property (nonatomic, retain) NSSet *inverseConveneRooms;
@property (nonatomic, retain) NSSet *inverseIncidentCategories;
@property (nonatomic, retain) BCMContactRole *role;
@property (nonatomic, retain) BCMUser *user;
@end

@interface BCMContact (CoreDataGeneratedAccessors)

- (void)addInverseAreaOfficesObject:(BCMAreaOffice *)value;
- (void)removeInverseAreaOfficesObject:(BCMAreaOffice *)value;
- (void)addInverseAreaOffices:(NSSet *)values;
- (void)removeInverseAreaOffices:(NSSet *)values;
- (void)addInverseConveneRoomsObject:(BCMConveneRoom *)value;
- (void)removeInverseConveneRoomsObject:(BCMConveneRoom *)value;
- (void)addInverseConveneRooms:(NSSet *)values;
- (void)removeInverseConveneRooms:(NSSet *)values;
- (void)addInverseIncidentCategoriesObject:(BCMIncidentCategory *)value;
- (void)removeInverseIncidentCategoriesObject:(BCMIncidentCategory *)value;
- (void)addInverseIncidentCategories:(NSSet *)values;
- (void)removeInverseIncidentCategories:(NSSet *)values;
@end
