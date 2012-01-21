//
//  BCMSLoginViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSLoginViewController
 @discussion This class controls the login view.
 
  Version 1.1 Modified for "BCMS Incident Management Portrait Prototype Assembly":

 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSLoginViewController : UIViewController <UITextFieldDelegate> {
    // The content view
    UIView *contentView;

    // The validation view
    UIView *validationView;

    // The username field
    UITextField *usernameField;

    // The password field
    UITextField *passwordField;

    // The privilege label
    UILabel *privilegeLabel;
    
    // The checkbox
    UIButton *checkboxButton;
    
    // The username view
    UIView *usernameView;
    
    // The password view
    UIView *passwordView;
    
    // The privilege view
    UIView *privilegeView;

    // The remember me view
    UIView *rememberMeView;
    
    // The web version view
    UIView *webVersionView;

    // The login button
    UIButton *loginButton;
    
    // The username text box image
    UIImageView *usernameImage;

    // The password text box image
    UIImageView *passwordImage;

    // The header image
    UIImageView *headerImage;
    
    // The dropdown button
    UIButton *dropDownButton;
    
    // The username label
    UILabel *usernameLabel;

    // The password label
    UILabel *passwordLabel;

    // The notification background
    UIImageView *notificationBg;
    
    // The try again button
    UIButton *tryAgainButton;
    
    // The notification message
    UILabel *notificationMessage;
    
    // The try again label
    UILabel *tryAgainLabel;
    
    // Whether checked
    BOOL checked;
}

// The content view
@property (nonatomic, retain) IBOutlet UIView *contentView;

// The content view
@property (nonatomic, retain) IBOutlet UIView *validationView;

// The username field
@property (nonatomic, retain) IBOutlet UITextField *usernameField;

// The password field
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

// The privilege label
@property (nonatomic, retain) IBOutlet UILabel *privilegeLabel;

// The checkbox
@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;

// The username view
@property (nonatomic, retain) IBOutlet UIView *usernameView;

// The password view
@property (nonatomic, retain) IBOutlet UIView *passwordView;

// The privilege view
@property (nonatomic, retain) IBOutlet UIView *privilegeView;

// The remember me view
@property (nonatomic, retain) IBOutlet UIView *rememberMeView;

// The web version view
@property (nonatomic, retain) IBOutlet UIView *webVersionView;

// The login button
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

// The username text box image
@property (nonatomic, retain) IBOutlet UIImageView *usernameImage;

// The password text box image
@property (nonatomic, retain) IBOutlet UIImageView *passwordImage;

// The header image
@property (nonatomic, retain) IBOutlet UIImageView *headerImage;

// The dropdown button
@property (nonatomic, retain) IBOutlet UIButton *dropDownButton;

// The username label
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;

// The password label
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;

// The notification background
@property (nonatomic, retain) IBOutlet UIImageView *notificationBg;

// The try again button
@property (nonatomic, retain) IBOutlet UIButton *tryAgainButton;

// The notification message
@property (nonatomic, retain) IBOutlet UILabel *notificationMessage;

// The try again label
@property (nonatomic, retain) IBOutlet UILabel *tryAgainLabel;

// Set the checkbox
- (void)setCheckbox;

// Validate the user input
// Return: YES if the input is valid.
- (BOOL)validateInput;

// Push a view controller
// Params:
//      notification: The notification
- (void)pushViewController:(NSNotification *)notification;

// Pop a number of view controllers
// Params:
//      notification: The notification
- (void)popViewController:(NSNotification *)notification;

// Reset the form
- (void) resetForm;

// Called when clicked the checkbox
// Params:
//      sender: The sender of the action
- (IBAction)checkboxClicked:(id)sender;

// Called when clicked the login button
// Params:
//      sender: The sender of the action
- (IBAction)loginClicked:(id)sender;

// Called when clicked the try again button
// Params:
//      sender: The sender of the action
- (IBAction)tryAgainClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
