//
//  BCMSMoreDetailsTableCell.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMoreDetailsTableCell.h"

@implementation BCMSMoreDetailsTableCell
@synthesize nameLabel;
@synthesize jobLabel;
@synthesize primaryLabel;
@synthesize secondaryLabel;
@synthesize primaryContactLabel;
@synthesize secondaryContactLabel;

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
