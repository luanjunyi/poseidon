//
//  BCMSIncidentsTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSIncidentsTableCell
 @discussion This class controls the Incidents table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSIncidentsTableCell : UITableViewCell {
    
    // The incident date label
    UILabel *incidentDateLabel;
    
    // The incident date label
    UILabel *incidentDetailLabel;
    
    // The incident location label
    UILabel *incidentLocationLabel;
    
    // The incident status label
    UILabel *incidentStatusLabel;
    
    // The icon image
    UIImageView *iconImage;
}

// The incident date label
@property (nonatomic, retain) IBOutlet UILabel *incidentDateLabel;

// The incident date label
@property (nonatomic, retain) IBOutlet UILabel *incidentDetailLabel;

// The incident location label
@property (nonatomic, retain) IBOutlet UILabel *incidentLocationLabel;

// The incident status label
@property (nonatomic, retain) IBOutlet UILabel *incidentStatusLabel;

// The icon image
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;

@end
