//
//  BCMSAddNoteViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSAddNoteViewController.h"
#import "BCMSHelper.h"

@implementation BCMSAddNoteViewController
@synthesize dateLabel;
@synthesize typeNoteLabel;
@synthesize noteTextView;
@synthesize incidentId;
@synthesize backgroundView;

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
    [BCMSHelper setupRoundView:backgroundView];
    self.dateLabel.text = [BCMSHelper convertDateToStringFormat2:[incidentDetails objectForKey:@"date"]];
}

// Unload
- (void)viewDidUnload
{
    self.dateLabel = nil;
    self.typeNoteLabel = nil;
    self.noteTextView = nil;
    self.backgroundView = nil;
    [super viewDidUnload];
}

// Called when clicked the close button
// Params:
//      sender: The sender of the action
- (IBAction)closeClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender {
    // Simple return in this Assembly
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
        [noteTextView setFrame:CGRectMake(28, 85, 421, 80)];
    }
    else {
        [noteTextView setFrame:CGRectMake(28, 85, 261, 195)];
    }
}

// Text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [typeNoteLabel setHidden:YES];
    return YES;
}

// Text view delegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [typeNoteLabel setHidden:NO];
    }
    return YES;
}

@end
