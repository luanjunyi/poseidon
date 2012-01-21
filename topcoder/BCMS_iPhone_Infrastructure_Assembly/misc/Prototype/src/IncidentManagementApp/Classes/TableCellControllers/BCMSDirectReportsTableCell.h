//
//  BCMSDirectReportsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSDirectReportsTableCell
 @discussion This class controls the Direct Reports table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSDirectReportsTableCell : UITableViewCell {
    
    // The report name
    UILabel *reportName;
   
    // The icon image
    UIImageView *iconImage;
    
    // The drop down view
    UIView *dropdownView;
}

// The report name
@property (nonatomic, retain) IBOutlet UILabel *reportName;

// The icon image
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;

// The drop down view
@property (nonatomic, retain) IBOutlet UIView *dropdownView;

@end
