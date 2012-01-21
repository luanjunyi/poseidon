//
//  BCMSAddConvenRoomController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSAddConvenRoomController
 @discussion This class controls the Add Convene Rooms view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSAddConvenRoomController : UIViewController <UITextFieldDelegate> {
    // The text background
    UIView *textBackground;
    
    // The cancel button
    UIButton *cancelButton;
    
    // The done button
    UIButton *doneButton;
}

// The text background
@property (nonatomic, retain) IBOutlet UIView *textBackground;

// The cancel button
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

// The done button
@property (nonatomic, retain) IBOutlet UIButton *doneButton;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender;

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
