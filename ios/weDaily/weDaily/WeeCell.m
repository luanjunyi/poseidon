//
//  WeeCell.m
//  weDaily
//
//  Created by luanjunyi on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeeCell.h"

@implementation WeeCell

@synthesize title, abstract, backImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
