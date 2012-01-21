//
//  BCMSConveneRoomsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSConveneRoomsTableCell
 @discussion This class controls the More Details table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSConveneRoomsTableCell : UITableViewCell {
    
    // The name label
    UILabel *nameLabel;

    // The office label
    UILabel *officeLabel;

    // The delete button
    UIButton *deleteButton;
}

// The name label
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

// The office label
@property (nonatomic, retain) IBOutlet UILabel *officeLabel;

// The delete button
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

@end
