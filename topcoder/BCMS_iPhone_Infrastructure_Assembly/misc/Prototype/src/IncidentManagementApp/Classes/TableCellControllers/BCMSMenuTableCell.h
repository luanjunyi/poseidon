//
//  BCMSMenuTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSMenuTableCell
 @discussion This class controls the menu table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSMenuTableCell : UITableViewCell {
    
    // The cell title
    UILabel *cellTitle;
    
    // The icon image
    UIImageView *iconImage;
    
    // The background image
    UIImageView *bgImage;
    
    // The accessory arrow image
    UIImageView *accessoryArrow;
    
    // The image path
    NSString *imagePath;
    
    // The highlighted image path
    NSString *imagePathHighlight;
}

// The cell title
@property (nonatomic, retain) IBOutlet UILabel *cellTitle;

// The icon image
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;

// The background image
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

// The accessory arrow image
@property (nonatomic, retain) IBOutlet UIImageView *accessoryArrow;

// The image path
@property (nonatomic, retain) NSString *imagePath;

// The highlighted image path
@property (nonatomic, retain) NSString *imagePathHighlight;

@end
