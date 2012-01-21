//
//  BCMSAddConvenRoomController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSAddConvenRoomController.h"
#import "BCMSHelper.h"

@implementation BCMSAddConvenRoomController
@synthesize textBackground;
@synthesize cancelButton;
@synthesize doneButton;

// Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

// Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [BCMSHelper setupRoundView:textBackground];
    [self doLayout:self.interfaceOrientation];
}

// Unload
- (void)viewDidUnload
{
    self.textBackground = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
    [super viewDidUnload];
}

// Return YES for supported orientations
// Params:
//      interfaceOrientation: The orientation
// Return: YES for supported orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self doLayout:interfaceOrientation];
    // Return YES for supported orientations
    return YES;
}

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender {
    // Simple go back to the previous view in this assembly.
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// The delegate for textFieldShouldReturn
// Params:
//      theTextField: The text field.
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(32, 8, 202, 52)];
        [doneButton setFrame:CGRectMake(246, 8, 202, 52)];
    }
    else {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button_p.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button_p.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(14, 8, 142, 52)];
        [doneButton setFrame:CGRectMake(165, 8, 142, 52)];
    }
}

@end
