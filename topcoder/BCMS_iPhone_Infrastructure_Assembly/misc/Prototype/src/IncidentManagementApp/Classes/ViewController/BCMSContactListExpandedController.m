//
//  BCMSContactListExpandedController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSContactListExpandedController.h"
#import "BCMSHelper.h"
#import "BCMSOptionsTableCell.h"
#import "BCMSContactDetailsController.h"

@implementation BCMSContactListExpandedController
@synthesize titleLabel;
@synthesize listType;
@synthesize tableInfo;
@synthesize acronymLabel;
@synthesize theTableView;

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
    tableList = [tableInfo objectForKey:@"items"];
    self.titleLabel.text = [tableInfo objectForKey:@"name"];
    self.acronymLabel.text = [tableInfo objectForKey:@"acronym"];
    [self doLayout:self.interfaceOrientation];
}

// Unload
- (void)viewDidUnload
{
    self.titleLabel = nil;
    self.acronymLabel = nil;
    self.theTableView = nil;
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
    myOrientation = orientation;
    [theTableView reloadData];
}

#pragma mark -
#pragma mark Table Data Source Methods
// The following methods are standard table data source and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"OptionsListCellIdentifier";
    
    // Prepare cell information
    NSUInteger section = [indexPath section];
    
	// Use customized cell
	BCMSOptionsTableCell *cell = (BCMSOptionsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    // Fill the cell properties
    cell.accessoryIcon.hidden = YES;
    cell.cellTitle.text = [[tableList objectAtIndex:section] objectForKey:@"name"];
    cell.optionsLabel.text = [[tableList objectAtIndex:section] objectForKey:@"title"];
    [cell.cellTitle setShadowOffset:CGSizeMake(0, 1)];
    [cell.optionsLabel setShadowOffset:CGSizeMake(0, 1)];
    cell.cellSeparator.hidden = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    if(UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cell.optionsLabel setFrame:CGRectMake(318, 0, 150, 43)];
    }
    else {
        [cell.optionsLabel setFrame:CGRectMake(190, 0, 120, 43)];
    }
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kContactListExpandedTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // load the contact details view.
    NSUInteger section = [indexPath section];
    BCMSContactDetailsController *detailsController = [[BCMSContactDetailsController alloc] initWithNibName:nil bundle:nil];
    detailsController.tableList = [[tableList objectAtIndex:section] objectForKey:@"details"];
    [BCMSHelper postNotification:PushViewNotification param:detailsController];
}

@end
