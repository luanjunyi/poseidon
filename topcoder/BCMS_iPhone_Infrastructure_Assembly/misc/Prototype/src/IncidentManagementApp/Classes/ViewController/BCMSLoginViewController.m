//
//  BCMSLoginViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSLoginViewController.h"
#import "BCMSMenuViewController.h"
#import "BCMSHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCMSLoginViewController
@synthesize contentView;
@synthesize validationView;
@synthesize usernameField;
@synthesize passwordField;
@synthesize privilegeLabel;
@synthesize checkboxButton;
@synthesize usernameView;
@synthesize passwordView;
@synthesize privilegeView;
@synthesize rememberMeView;
@synthesize webVersionView;
@synthesize loginButton;
@synthesize usernameImage;
@synthesize passwordImage;
@synthesize headerImage;
@synthesize dropDownButton;
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize notificationBg;
@synthesize tryAgainButton;
@synthesize notificationMessage;
@synthesize tryAgainLabel;
// Dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        checked = NO;
    }
    return self;
}

#pragma mark - View lifecycle
// Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [contentView.layer setCornerRadius:10.0];
    [self setCheckbox];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(pushViewController:) name:@"PushViewNotification" object:nil];
    [center addObserver:self selector:@selector(popViewController:) name:@"PopViewNotification" object:nil];
}

// Dealloc
- (void)viewDidUnload
{
    self.contentView = nil;
    self.usernameField = nil;
    self.passwordField = nil;
    self.privilegeLabel = nil;
    self.checkboxButton = nil;
    self.usernameView = nil;
    self.passwordView = nil;
    self.privilegeView = nil;
    self.rememberMeView = nil;
    self.webVersionView = nil;
    self.loginButton = nil;
    self.usernameImage = nil;
    self.passwordImage = nil;
    self.headerImage = nil;
    self.dropDownButton = nil;
    self.usernameLabel = nil;
    self.passwordLabel = nil;
    self.notificationBg = nil;
    self.tryAgainButton = nil;
    self.notificationMessage = nil;
    self.tryAgainLabel = nil;
    [super viewDidUnload];
}

// Return YES for supported orientations
// Params:
//      interfaceOrientation: The orientation
// Return: YES for supported orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    [self doLayout:interfaceOrientation];
    return YES;
}

// Set the checkbox
- (void)setCheckbox {
    if (checked) {
        [checkboxButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
    }
    else {
        [checkboxButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    }
}

// Validate the user input
// Return: YES if the input is valid.
- (BOOL)validateInput {
    // In this assembly, only check if the username and password are empty.
    NSString *usernameText = [usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordText = [passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSDictionary *userinfo = [[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"userinfo"];
    if (![usernameText isEqualToString:[userinfo objectForKey:@"username"]] || ![passwordText isEqualToString:[userinfo objectForKey:@"password"]]) {
        return NO;
    }

    return YES;
}

// Push a view controller
// Params:
//      notification: The notification
- (void)pushViewController:(NSNotification *)notification {
    id viewController = [notification object];
    [self.navigationController pushViewController:viewController animated:YES];
}

// Pop a number of view controllers
// Params:
//      notification: The notification
- (void)popViewController:(NSNotification *)notification {
    int num = 1;
    if (notification != nil && notification.object != nil) {
        num = [[notification object] intValue];
    }
    for (int i = 0; i < num; i++) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[self.navigationController topViewController] shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

// Reset the form
- (void) resetForm {
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    checked = NO;
    [self setCheckbox];
}

// Called when clicked the checkbox
// Params:
//      sender: The sender of the action
- (IBAction)checkboxClicked:(id)sender {
    checked = !checked;
    [self setCheckbox];
}

// Called when clicked the login button
// Params:
//      sender: The sender of the action
- (IBAction)loginClicked:(id)sender {
    if ([self validateInput]) {
        // Login successful.
        BCMSMenuViewController *menuViewController = [[BCMSMenuViewController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:menuViewController];
        [self performSelector:@selector(resetForm) withObject:nil afterDelay:0.5];
    }
    else {
        // Login failed.
        [BCMSHelper fadeViewIn:validationView parentView:self.view];
    }
}

// Called when clicked the try again button
// Params:
//      sender: The sender of the action
- (IBAction)tryAgainClicked:(id)sender {
    [BCMSHelper fadeViewOut:validationView parentView:self.view];
}

// The delegate for textFieldShouldReturn
// Params:
//      theTextField: The text field.
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if ([theTextField isEqual:usernameField] && [passwordField.text isEqualToString:@""]) {
        [passwordField becomeFirstResponder];
    }
    else {
        [theTextField resignFirstResponder];
    }
    return YES;
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [usernameLabel setFrame:CGRectMake(19, 82, 101, 27)];
        [passwordLabel setFrame:CGRectMake(19, 126, 101, 27)];
        [privilegeLabel setFrame:CGRectMake(19, 169, 101, 27)];
        [usernameView setFrame:CGRectMake(150, 80, 290, 31)];
        [passwordView setFrame:CGRectMake(150, 124, 290, 31)];
        [privilegeView setFrame:CGRectMake(150, 167, 290, 31)];
        [rememberMeView setFrame:CGRectMake(19, 204, 158, 31)];
        [webVersionView setFrame:CGRectMake(282, 204, 158, 31)];
        [loginButton setImage:[UIImage imageNamed:@"login_button.png"] forState:UIControlStateNormal];
        headerImage.image = [UIImage imageNamed:@"login_header.png"];
        [notificationBg setFrame:CGRectMake(63, 98, 355, 123)];
        notificationBg.image = [UIImage imageNamed:@"notification_bg1.png"];
        [notificationMessage setFont:[UIFont fontWithName:@"Helvetica" size:23]];
        [notificationMessage setFrame:CGRectMake(83, 112, 322, 21)];
        [tryAgainButton setFrame:CGRectMake(177, 158, 134, 47)];
        [tryAgainLabel setFrame:CGRectMake(204, 168, 81, 28)];
    }
    else {
        [usernameLabel setFrame:CGRectMake(9, 87, 101, 27)];
        [passwordLabel setFrame:CGRectMake(9, 164, 101, 27)];
        [privilegeLabel setFrame:CGRectMake(9, 239, 101, 27)];
        [usernameView setFrame:CGRectMake(9, 116, 282, 31)];
        [passwordView setFrame:CGRectMake(9, 193, 282, 31)];
        [privilegeView setFrame:CGRectMake(9, 270, 282, 31)];
        [rememberMeView setFrame:CGRectMake(7, 313, 158, 31)];
        [webVersionView setFrame:CGRectMake(71, 361, 158, 31)];
        [loginButton setImage:[UIImage imageNamed:@"login_button_p.png"] forState:UIControlStateNormal];
        headerImage.image = [UIImage imageNamed:@"login_header_p.png"];
        [notificationBg setFrame:CGRectMake(20, 154, 280, 123)];
        notificationBg.image = [UIImage imageNamed:@"notification_bg1_p.png"];
        [notificationMessage setFrame:CGRectMake(24, 164, 273, 21)];
        [notificationMessage setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [tryAgainButton setFrame:CGRectMake(95, 210, 134, 47)];
        [tryAgainLabel setFrame:CGRectMake(122, 220, 81, 28)];
    }
}

@end
