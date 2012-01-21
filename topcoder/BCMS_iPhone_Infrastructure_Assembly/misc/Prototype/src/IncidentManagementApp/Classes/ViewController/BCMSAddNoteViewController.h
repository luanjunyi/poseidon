//
//  BCMSAddNoteViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSAddNoteViewController
 @discussion This class controls the Add Note View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSAddNoteViewController : UIViewController <UITextViewDelegate> {
    // The date label
    UILabel *dateLabel;
    
    // The type note label
    UILabel *typeNoteLabel;
    
    // The text view
    UITextView *noteTextView;
    
    // The background view
    UIView *backgroundView;
    
    // The incident id.
    int incidentId;
}

// The date label
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

// The type note label
@property (nonatomic, retain) IBOutlet UILabel *typeNoteLabel;

// The text view
@property (nonatomic, retain) IBOutlet UITextView *noteTextView;

// The background view
@property (nonatomic, retain) IBOutlet UIView *backgroundView;

// The incident id.
@property (nonatomic, assign) int incidentId;

// Called when clicked the close button
// Params:
//      sender: The sender of the action
- (IBAction)closeClicked:(id)sender;

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
