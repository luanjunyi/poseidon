//
//  BCMSNoteDetailsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSNoteDetailsController
 @discussion This class controls the Notes Details View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSNoteDetailsController : UIViewController {
    // The date label
    UILabel *dateLabel;
    
    // The title label
    UILabel *titleLabel;    
    
    // The details text view
    UITextView *detailsTextView;
    
    // The confirmation view
    UIView *confirmationView;
    
    // The text background view
    UIView *backgroundView;
    
    // The notification background view
    UIView *notificationBgView;

    // The notification background image
    UIImageView *notificationBg;

    // The incident id.
    int incidentId;
    
    // The note id.
    int noteId;
}

// The date label
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;    

// The details text view
@property (nonatomic, retain) IBOutlet UITextView *detailsTextView;

// The confirmation view
@property (nonatomic, retain) IBOutlet UIView *confirmationView;

// The text background view
@property (nonatomic, retain) IBOutlet UIView *backgroundView;

// The notification background view
@property (nonatomic, retain) IBOutlet UIView *notificationBgView;

// The notification background image
@property (nonatomic, retain) IBOutlet UIImageView *notificationBg;

// The incident id.
@property (nonatomic, assign) int incidentId;

// The note id.
@property (nonatomic, assign) int noteId;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the delete button
// Params:
//      sender: The sender of the action
- (IBAction)deleteClicked:(id)sender;

// Called when clicked the email button
// Params:
//      sender: The sender of the action
- (IBAction)emailClicked:(id)sender;

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender;

// Called when clicked the Yes button
// Params:
//      sender: The sender of the action
- (IBAction)yesClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
