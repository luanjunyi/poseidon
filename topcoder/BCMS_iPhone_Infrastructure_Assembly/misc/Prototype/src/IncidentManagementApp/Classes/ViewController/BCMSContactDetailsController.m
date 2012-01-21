//
//  BCMSContactDetailsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSContactDetailsController.h"
#import "BCMSContactDetailsTableCell.h"
#import "BCMSHelper.h"

@implementation BCMSContactDetailsController
@synthesize tableList;
@synthesize theTableView;
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
    [theTableView reloadData];
    CGRect tableFrame = theTableView.frame;
    tableFrame.size.height = theTableView.contentSize.height;
    [theTableView setFrame:tableFrame];
}

// Unload
- (void)viewDidUnload
{
    self.theTableView = nil;
    self.scrollView = nil;
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

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [scrollView setContentSize:CGSizeMake(480, theTableView.frame.origin.y + theTableView.frame.size.height)];
    }
    else {
        [scrollView setContentSize:CGSizeMake(320, theTableView.frame.origin.y + theTableView.frame.size.height)];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
// The following methods are standard table data source and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	return [tableList count];
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"ContactDetailsCellIdentifier";
    
    // Prepare cell information
    NSUInteger row = [indexPath row];
    
	// Use customized cell
	BCMSContactDetailsTableCell *cell = (BCMSContactDetailsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSContactDetailsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    // Fill the cell properties.
    cell.phoneType.text = [[tableList objectAtIndex:row] objectForKey:@"name"];
    cell.phoneNumber.text = [[tableList objectAtIndex:row] objectForKey:@"number"];
    cell.iconImage.image = [UIImage imageNamed:[[tableList objectAtIndex:row] objectForKey:@"icon"]];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kContactDetailsTableCellheight;
}

@end
