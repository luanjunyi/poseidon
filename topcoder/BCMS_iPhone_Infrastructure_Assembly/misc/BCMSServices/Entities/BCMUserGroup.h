//
//  BCMUserGroup.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncidentAttachment, BCMIncidentNote, BCMIncidentUpdate, BCMUser;

@interface BCMUserGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviationName;
@property (nonatomic, retain) NSSet *inverseIncidentAttachments;
@property (nonatomic, retain) NSSet *inverseIncidentNotes;
@property (nonatomic, retain) NSSet *inverseIncidentUpdates;
@property (nonatomic, retain) NSSet *inverseUsers;
@end

@interface BCMUserGroup (CoreDataGeneratedAccessors)

- (void)addInverseIncidentAttachmentsObject:(BCMIncidentAttachment *)value;
- (void)removeInverseIncidentAttachmentsObject:(BCMIncidentAttachment *)value;
- (void)addInverseIncidentAttachments:(NSSet *)values;
- (void)removeInverseIncidentAttachments:(NSSet *)values;
- (void)addInverseIncidentNotesObject:(BCMIncidentNote *)value;
- (void)removeInverseIncidentNotesObject:(BCMIncidentNote *)value;
- (void)addInverseIncidentNotes:(NSSet *)values;
- (void)removeInverseIncidentNotes:(NSSet *)values;
- (void)addInverseIncidentUpdatesObject:(BCMIncidentUpdate *)value;
- (void)removeInverseIncidentUpdatesObject:(BCMIncidentUpdate *)value;
- (void)addInverseIncidentUpdates:(NSSet *)values;
- (void)removeInverseIncidentUpdates:(NSSet *)values;
- (void)addInverseUsersObject:(BCMUser *)value;
- (void)removeInverseUsersObject:(BCMUser *)value;
- (void)addInverseUsers:(NSSet *)values;
- (void)removeInverseUsers:(NSSet *)values;
@end
