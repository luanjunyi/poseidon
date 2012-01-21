//
//  BCMSMenuTableCell.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMenuTableCell.h"

@implementation BCMSMenuTableCell
@synthesize cellTitle;
@synthesize iconImage;
@synthesize bgImage;
@synthesize imagePath;
@synthesize imagePathHighlight;
@synthesize accessoryArrow;

// Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

// SetHighlighted delegate
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        iconImage.image = [UIImage imageNamed:imagePathHighlight];
        cellTitle.textColor = [UIColor whiteColor];
        cellTitle.shadowColor = [UIColor blackColor];
        cellTitle.shadowOffset = CGSizeMake(0, -1);
        accessoryArrow.image = [UIImage imageNamed:@"accessory_arrow_highlight.png"];
        bgImage.image = [UIImage imageNamed:@"menu_cell_highlight_bg.png"];
    }
    else {
        iconImage.image = [UIImage imageNamed:imagePath];
        cellTitle.textColor = [UIColor blackColor];
        cellTitle.shadowColor = [UIColor whiteColor];
        cellTitle.shadowOffset = CGSizeMake(0, 1);
        accessoryArrow.image = [UIImage imageNamed:@"accessory_arrow.png"];
        bgImage.image = nil;
    }
}
@end
