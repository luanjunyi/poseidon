//
//  BCMSConveneRoomsTableCell.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSConveneRoomsTableCell.h"

@implementation BCMSConveneRoomsTableCell
@synthesize nameLabel;
@synthesize officeLabel;
@synthesize deleteButton;

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
