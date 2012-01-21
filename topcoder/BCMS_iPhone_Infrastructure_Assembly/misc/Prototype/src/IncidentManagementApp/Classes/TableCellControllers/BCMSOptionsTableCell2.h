//
//  BCMSOptionsTableCell2.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSOptionsTableCell2
 @discussion This class controls the Options Table Cell 2.
 
 @author subchap
 @version 1.0
 */
@interface BCMSOptionsTableCell2 : UITableViewCell {
    
    // The cell title
    UILabel *cellTitle;
    
    // The selection image
    UIImageView *selectionImage;
    
    // The separator image
    UIImageView *separatorImage;
}

// The cell title
@property (nonatomic, retain) IBOutlet UILabel *cellTitle;

// The selection image
@property (nonatomic, retain) IBOutlet UIImageView *selectionImage;

// The separator image
@property (nonatomic, retain) IBOutlet UIImageView *separatorImage;

@end
