//
//  WeeCell.h
//  weDaily
//
//  Created by luanjunyi on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeeCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *title;
@property(nonatomic, weak) IBOutlet UILabel *abstract;
@property(nonatomic, weak) IBOutlet UIImageView *backImageView;


@end
