//
//  BCMIncidentNote.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncident, BCMUserGroup;

@interface BCMIncidentNote : NSManagedObject

@property (nonatomic, retain) NSString * addedBy;
@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * incidentId;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) BCMIncident *inverseIncident;
@end

@interface BCMIncidentNote (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(BCMUserGroup *)value;
- (void)removeGroupsObject:(BCMUserGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
@end
