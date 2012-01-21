//
//  BCMIncident.m
//  BCMSServices
//
//  Created by proxi on 11-12-17.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncident.h"
#import "BCMAdditionalInfo.h"
#import "BCMAreaOffice.h"
#import "BCMConveneRoom.h"
#import "BCMIncidentAssociation.h"
#import "BCMIncidentAttachment.h"
#import "BCMIncidentCategory.h"
#import "BCMIncidentNote.h"
#import "BCMIncidentStatus.h"
#import "BCMIncidentType.h"
#import "BCMIncidentUpdate.h"
#import "BCMUser.h"


@implementation BCMIncident

@dynamic approvedBy;
@dynamic approvedByJobTitle;
@dynamic id;
@dynamic incident;
@dynamic incidentNumber;
@dynamic incidentTitle;
@dynamic name;
@dynamic reportedBy;
@dynamic reportedByJobTitle;
@dynamic reportedDate;
@dynamic additionalInfo;
@dynamic attachments;
@dynamic category;
@dynamic cmt;
@dynamic inversePrimaryIncidentAssociations;
@dynamic inverseSecondaryIncidentAssociations;
@dynamic ism;
@dynamic location;
@dynamic notes;
@dynamic status;
@dynamic type;
@dynamic updates;

@end
