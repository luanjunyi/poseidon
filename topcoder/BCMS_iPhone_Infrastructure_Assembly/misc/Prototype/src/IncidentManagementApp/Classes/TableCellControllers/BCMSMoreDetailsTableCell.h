//
//  BCMSMoreDetailsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSMoreDetailsTableCell
 @discussion This class controls the More Details table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSMoreDetailsTableCell : UITableViewCell {
    
    // The name label
    UILabel *nameLabel;

    // The job label
    UILabel *jobLabel;

    // The primary phone label
    UILabel *primaryLabel;

    // The secondary label
    UILabel *secondaryLabel;
    
    // The primary contact label
    UILabel *primaryContactLabel;
    
    // The secondary contact label
    UILabel *secondaryContactLabel;
}

// The name label
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

// The job label
@property (nonatomic, retain) IBOutlet UILabel *jobLabel;

// The primary phone label
@property (nonatomic, retain) IBOutlet UILabel *primaryLabel;

// The secondary label
@property (nonatomic, retain) IBOutlet UILabel *secondaryLabel;

// The primary contact label
@property (nonatomic, retain) IBOutlet UILabel *primaryContactLabel;

// The secondary contact label
@property (nonatomic, retain) IBOutlet UILabel *secondaryContactLabel;

@end
