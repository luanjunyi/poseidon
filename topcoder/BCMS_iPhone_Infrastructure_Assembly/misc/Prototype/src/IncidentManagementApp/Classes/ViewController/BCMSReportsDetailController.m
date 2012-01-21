//
//  BCMSReportsDetailController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSReportsDetailController.h"
#import "BCMSHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCMSReportsDetailController
@synthesize nameLabel;
@synthesize reportTextView;
@synthesize contentView;
@synthesize reportId;
@synthesize personId;
@synthesize scrollView;

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
    NSDictionary *reportDetails = [[[[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"contacts"] objectAtIndex:2] objectForKey:@"items"] objectAtIndex:reportId] objectForKey:@"items"] objectAtIndex:personId];
    
    self.nameLabel.text = [reportDetails objectForKey:@"name"];
    self.reportTextView.text = [reportDetails objectForKey:@"details"];
    
    // set the view sizes
    contentView.layer.borderColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
    contentView.layer.borderWidth = 1.0;
    [contentView.layer setCornerRadius:10.0];
    [self doLayout:self.interfaceOrientation];
}

// Unload
- (void)viewDidUnload
{
    self.nameLabel = nil;
    self.reportTextView = nil;
    self.contentView = nil;
    self.scrollView = nil;

    [super viewDidUnload];
}

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the reply button
// Params:
//      sender: The sender of the action
- (IBAction)replyClicked:(id)sender {
    // Do nothing in this assembly
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

// Setup the content size of the scroll view
- (void)setupScrollView {
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size.height = reportTextView.contentSize.height + 30;
    [contentView setFrame:contentViewFrame];
    CGRect textViewFrame = reportTextView.frame;
    textViewFrame.size.height = reportTextView.contentSize.height;
    [reportTextView setFrame:textViewFrame];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, contentViewFrame.origin.y + contentViewFrame.size.height)];
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.1];
}

@end
