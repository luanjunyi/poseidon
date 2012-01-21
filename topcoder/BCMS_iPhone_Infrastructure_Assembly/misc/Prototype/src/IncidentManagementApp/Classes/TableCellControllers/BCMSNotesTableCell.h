//
//  BCMSNotesTableCell.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSNotesTableCell
 @discussion This class controls the notes table cell.
 
 @author subchap
 @version 1.0
 */
@interface BCMSNotesTableCell : UITableViewCell {
    
    // The note date label
    UILabel *noteDateLabel;
    
    // The note date label
    UILabel *noteDetailLabel;
    
    // The delete button
    UIButton *deleteButton;
}

// The note date label
@property (nonatomic, retain) IBOutlet UILabel *noteDateLabel;

// The note date label
@property (nonatomic, retain) IBOutlet UILabel *noteDetailLabel;

// The delete button
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

@end
