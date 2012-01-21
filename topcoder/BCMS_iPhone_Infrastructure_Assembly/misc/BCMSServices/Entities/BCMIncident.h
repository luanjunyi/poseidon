//
//  BCMIncident.h
//  BCMSServices
//
//  Created by proxi on 11-12-17.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMAdditionalInfo, BCMAreaOffice, BCMConveneRoom, BCMIncidentAssociation, BCMIncidentAttachment, BCMIncidentCategory, BCMIncidentNote, BCMIncidentStatus, BCMIncidentType, BCMIncidentUpdate, BCMUser;

@interface BCMIncident : NSManagedObject

@property (nonatomic, retain) NSString * approvedBy;
@property (nonatomic, retain) NSString * approvedByJobTitle;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * incident;
@property (nonatomic, retain) NSNumber * incidentNumber;
@property (nonatomic, retain) NSString * incidentTitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reportedBy;
@property (nonatomic, retain) NSString * reportedByJobTitle;
@property (nonatomic, retain) NSDate * reportedDate;
@property (nonatomic, retain) NSSet *additionalInfo;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) BCMIncidentCategory *category;
@property (nonatomic, retain) BCMConveneRoom *cmt;
@property (nonatomic, retain) BCMIncidentAssociation *inversePrimaryIncidentAssociations;
@property (nonatomic, retain) NSSet *inverseSecondaryIncidentAssociations;
@property (nonatomic, retain) BCMUser *ism;
@property (nonatomic, retain) BCMAreaOffice *location;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) BCMIncidentStatus *status;
@property (nonatomic, retain) BCMIncidentType *type;
@property (nonatomic, retain) NSSet *updates;
@end

@interface BCMIncident (CoreDataGeneratedAccessors)

- (void)addAdditionalInfoObject:(BCMAdditionalInfo *)value;
- (void)removeAdditionalInfoObject:(BCMAdditionalInfo *)value;
- (void)addAdditionalInfo:(NSSet *)values;
- (void)removeAdditionalInfo:(NSSet *)values;
- (void)addAttachmentsObject:(BCMIncidentAttachment *)value;
- (void)removeAttachmentsObject:(BCMIncidentAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;
- (void)addInverseSecondaryIncidentAssociationsObject:(BCMIncidentAssociation *)value;
- (void)removeInverseSecondaryIncidentAssociationsObject:(BCMIncidentAssociation *)value;
- (void)addInverseSecondaryIncidentAssociations:(NSSet *)values;
- (void)removeInverseSecondaryIncidentAssociations:(NSSet *)values;
- (void)addNotesObject:(BCMIncidentNote *)value;
- (void)removeNotesObject:(BCMIncidentNote *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;
- (void)addUpdatesObject:(BCMIncidentUpdate *)value;
- (void)removeUpdatesObject:(BCMIncidentUpdate *)value;
- (void)addUpdates:(NSSet *)values;
- (void)removeUpdates:(NSSet *)values;
@end
