//
//  BCMSOptionsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSOptionsTableCell
 @discussion This class controls the Options Table Cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSOptionsTableCell : UITableViewCell {
    
    // The cell title
    UILabel *cellTitle;
    
    // The options label
    UILabel *optionsLabel;
    
    // Cell separator
    UIImageView *cellSeparator;
    
    // Accessory icon
    UIImageView *accessoryIcon;
}

// The cell title
@property (nonatomic, retain) IBOutlet UILabel *cellTitle;

// The cell title
@property (nonatomic, retain) IBOutlet UILabel *optionsLabel;

// Cell separator
@property (nonatomic, retain) IBOutlet UIImageView *cellSeparator;

// Accessory icon
@property (nonatomic, retain) IBOutlet UIImageView *accessoryIcon;

@end
