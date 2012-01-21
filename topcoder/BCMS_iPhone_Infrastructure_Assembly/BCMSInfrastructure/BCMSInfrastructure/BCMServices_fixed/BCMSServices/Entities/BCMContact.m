//
//  BCMContact.m
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMContact.h"
#import "BCMAreaOffice.h"
#import "BCMContactRole.h"
#import "BCMConveneRoom.h"
#import "BCMIncidentCategory.h"
#import "BCMUser.h"


@implementation BCMContact

@dynamic id;
@dynamic name;
@dynamic primaryNumber;
@dynamic secondaryNumber;
@dynamic jobTitle;
@dynamic inverseAreaOffices;
@dynamic inverseConveneRooms;
@dynamic inverseIncidentCategories;
@dynamic role;
@dynamic user;

@end
