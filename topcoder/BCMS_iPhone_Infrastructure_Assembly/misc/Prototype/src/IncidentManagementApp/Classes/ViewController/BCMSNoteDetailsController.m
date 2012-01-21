//
//  BCMSNoteDetailsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSNoteDetailsController.h"
#import "BCMSHelper.h"

@implementation BCMSNoteDetailsController
@synthesize dateLabel;
@synthesize detailsTextView;
@synthesize titleLabel;
@synthesize incidentId;
@synthesize noteId;
@synthesize confirmationView;
@synthesize backgroundView;
@synthesize notificationBgView;
@synthesize notificationBg;

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
    NSDictionary *incidentDetails = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId];
    
    self.dateLabel.text = [BCMSHelper convertDateToStringFormat2:[incidentDetails objectForKey:@"date"]];
    self.detailsTextView.text = [[[incidentDetails objectForKey:@"notes"] objectAtIndex:noteId] objectForKey:@"details"];
    
    // Get the first two words
    NSInteger nWords = 2;
    NSRange wordRange = NSMakeRange(0,nWords);
    NSArray *firstWords = [[self.detailsTextView.text componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (note detail)",[firstWords componentsJoinedByString:@" "]];
    [BCMSHelper setupRoundView:backgroundView];
}

// Unload
- (void)viewDidUnload
{
    self.dateLabel = nil;
    self.titleLabel = nil;    
    self.detailsTextView = nil;
    self.confirmationView = nil;
    self.backgroundView = nil;
    self.notificationBgView = nil;
    self.notificationBg = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the delete button
// Params:
//      sender: The sender of the action
- (IBAction)deleteClicked:(id)sender {
    [BCMSHelper fadeViewIn:confirmationView parentView:self.view];
}

// Called when clicked the email button
// Params:
//      sender: The sender of the action
- (IBAction)emailClicked:(id)sender {
    // Does nothing in this assembly
}

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender {
    [BCMSHelper fadeViewOut:confirmationView parentView:self.view];
}

// Called when clicked the Yes button
// Params:
//      sender: The sender of the action
- (IBAction)yesClicked:(id)sender {
    // Simply go back to the previous screen in this assembly.
    [BCMSHelper postNotification:PopViewNotification param:nil];
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

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [dateLabel setFrame:CGRectMake(208, 51, 261, 26)];
        [dateLabel setTextAlignment:UITextAlignmentRight];
        [backgroundView setFrame:CGRectMake(11, 80, 458, 183)];
        [notificationBgView setFrame:CGRectMake(40, 63, 400, 109)];
        [notificationBg setImage:[UIImage imageNamed:@"notification_bg3.png"]];
        [detailsTextView setFrame:CGRectMake(20, 86, 440, 167)];
    }
    else {
        [dateLabel setFrame:CGRectMake(11, 70, 261, 26)];
        [dateLabel setTextAlignment:UITextAlignmentLeft];
        [backgroundView setFrame:CGRectMake(11, 100, 298, 323)];
        [notificationBgView setFrame:CGRectMake(10, 121, 300, 109)];
        [notificationBg setImage:[UIImage imageNamed:@"notification_bg3_p.png"]];
        [detailsTextView setFrame:CGRectMake(20, 106, 280, 300)];
    }
}

@end
