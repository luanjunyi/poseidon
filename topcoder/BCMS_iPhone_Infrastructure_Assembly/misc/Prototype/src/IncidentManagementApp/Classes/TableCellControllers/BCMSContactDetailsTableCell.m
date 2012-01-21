//
//  BCMSContactDetailsTableCell.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSContactDetailsTableCell.h"

@implementation BCMSContactDetailsTableCell
@synthesize phoneType;
@synthesize phoneNumber;
@synthesize iconImage;
@synthesize backgroundImage;

// Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
