//
//  BCMUserGroup.m
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUserGroup.h"
#import "BCMIncidentAttachment.h"
#import "BCMIncidentNote.h"
#import "BCMIncidentUpdate.h"
#import "BCMUser.h"


@implementation BCMUserGroup

@dynamic id;
@dynamic name;
@dynamic abbreviationName;
@dynamic inverseIncidentAttachments;
@dynamic inverseIncidentNotes;
@dynamic inverseIncidentUpdates;
@dynamic inverseUsers;

@end
