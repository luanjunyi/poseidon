//
//  BCMUser.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMContact, BCMIncident, BCMUserGroup;

@interface BCMUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * employeeName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *inverseContacts;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *inverseIncidentsIsm;
@end

@interface BCMUser (CoreDataGeneratedAccessors)

- (void)addInverseContactsObject:(BCMContact *)value;
- (void)removeInverseContactsObject:(BCMContact *)value;
- (void)addInverseContacts:(NSSet *)values;
- (void)removeInverseContacts:(NSSet *)values;
- (void)addGroupsObject:(BCMUserGroup *)value;
- (void)removeGroupsObject:(BCMUserGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
- (void)addInverseIncidentsIsmObject:(BCMIncident *)value;
- (void)removeInverseIncidentsIsmObject:(BCMIncident *)value;
- (void)addInverseIncidentsIsm:(NSSet *)values;
- (void)removeInverseIncidentsIsm:(NSSet *)values;
@end
