//
//  BCMSSettingsDetailController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSSettingsDetailController.h"
#import "BCMSHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCMSSettingsDetailController
@synthesize nameLabel;
@synthesize titleLabel;
@synthesize detailTextView;
@synthesize contentView;
@synthesize scrollView;
@synthesize settingType;
@synthesize detailId;

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
    NSDictionary *settingDetails = [[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"settings"] objectAtIndex:settingType] objectForKey:@"items"] objectAtIndex:detailId];  
    self.nameLabel.text = [settingDetails objectForKey:@"name"];
    self.detailTextView.text = [settingDetails objectForKey:@"details"];
    self.titleLabel.text = [settingDetails objectForKey:@"title"];

    [BCMSHelper setupRoundView:contentView];
    [self doLayout:self.interfaceOrientation];
}

// Unload
- (void)viewDidUnload
{
    self.nameLabel = nil;
    self.titleLabel = nil;
    self.detailTextView = nil;
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

// Setup the scroll view
- (void)setupScrollView {
    // set the view sizes
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size.height = detailTextView.contentSize.height + 30;
    [contentView setFrame:contentViewFrame];
    CGRect textViewFrame = detailTextView.frame;
    textViewFrame.size.height = detailTextView.contentSize.height;
    [detailTextView setFrame:textViewFrame];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, contentViewFrame.origin.y + contentViewFrame.size.height)];
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.1];
}

@end
