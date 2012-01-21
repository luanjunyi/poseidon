//
//  BCMSReportsDetailController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSReportsDetailController
 @discussion This class controls the Direct Reports detail view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSReportsDetailController : UIViewController <UITextViewDelegate> {
    // The name label
    UILabel *nameLabel;

    // The report text view
    UITextView *reportTextView;
    
    // The content view
    UIView *contentView;
    
    // The scroll view
    UIScrollView *scrollView;
    
    // The report id.
    int reportId;
    
    // The person id
    int personId;
}

// The name label
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

// The report text view
@property (nonatomic, retain) IBOutlet UITextView *reportTextView;

// The content view
@property (nonatomic, retain) IBOutlet UIView *contentView;

// The scroll view
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// The report id.
@property (nonatomic, assign) int reportId;

// The person id
@property (nonatomic, assign) int personId;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the reply button
// Params:
//      sender: The sender of the action
- (IBAction)replyClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
