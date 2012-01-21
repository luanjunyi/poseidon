//
//  BCMSContactDetailsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSContactDetailsTableCell
 @discussion This class controls the Contact Details table cell.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.

 @author subchap
 @version 1.1
 */
@interface BCMSContactDetailsTableCell : UITableViewCell {
    
    // The phone type
    UILabel *phoneType;

    // The phone number
    UILabel *phoneNumber;
    
    // The icon image
    UIImageView *iconImage;
    
    // The background image
    UIImageView *backgroundImage;
}

// The phone type
@property (nonatomic, retain) IBOutlet UILabel *phoneType;

// The phone number
@property (nonatomic, retain) IBOutlet UILabel *phoneNumber;

// The icon image
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;

// The background image
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;

@end
