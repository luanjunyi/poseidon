//
//  BCMIncidentAttachment.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncident, BCMUserGroup;

@interface BCMIncidentAttachment : NSManagedObject

@property (nonatomic, retain) NSString * addedBy;
@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) NSString * downloadLink;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * incidentId;
@property (nonatomic, retain) NSString * tempId;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) BCMIncident *inverseIncident;
@end

@interface BCMIncidentAttachment (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(BCMUserGroup *)value;
- (void)removeGroupsObject:(BCMUserGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
@end
