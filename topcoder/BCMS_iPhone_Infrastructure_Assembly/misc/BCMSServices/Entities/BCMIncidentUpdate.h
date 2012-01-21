//
//  BCMIncidentUpdate.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncident, BCMUserGroup;

@interface BCMIncidentUpdate : NSManagedObject

@property (nonatomic, retain) NSNumber * alertSent;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * incidentId;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) BCMIncident *inverseIncident;
@end

@interface BCMIncidentUpdate (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(BCMUserGroup *)value;
- (void)removeGroupsObject:(BCMUserGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
@end
