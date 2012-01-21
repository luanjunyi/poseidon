//
//  BCMSIncidentsViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSIncidentsViewController.h"
#import "BCMSHelper.h"
#import "BCMSIncidentsTableCell.h"
#import "BCMSIncidentFilterSortController.h"
#import "BCMSNewIncidentController.h"
#import "BCMSIncidentDetailsController.h"

@implementation BCMSIncidentsViewController
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
    incidentsList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"];
}

// Unload
- (void)viewDidUnload
{
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

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the filter button
// Params:
//      sender: The sender of the action
- (IBAction)filterClicked:(id)sender {
    BCMSIncidentFilterSortController *filterSortController = [[BCMSIncidentFilterSortController alloc] initWithNibName:nil bundle:nil];
    [BCMSHelper postNotification:PushViewNotification param:filterSortController];
}

// Called when clicked the add new incident button
// Params:
//      sender: The sender of the action
- (IBAction)addNewIncidentClicked:(id)sender {
    BCMSNewIncidentController *newIncidentController = [[BCMSNewIncidentController alloc] initWithNibName:nil bundle:nil];
    [BCMSHelper postNotification:PushViewNotification param:newIncidentController];
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	return [incidentsList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *cellIdentifier = @"IncidentsListCellIdentifier";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [incidentsList objectAtIndex:row];
    
	// Use customized cell
	BCMSIncidentsTableCell *cell = (BCMSIncidentsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSIncidentsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    NSDate *incidentDate = [cellInfo objectForKey:@"date"];
    cell.incidentDateLabel.text = [BCMSHelper convertDateToString:incidentDate];
    cell.incidentDetailLabel.text = [cellInfo objectForKey:@"description"];
    cell.incidentLocationLabel.text = [cellInfo objectForKey:@"address"];
    
    NSString *status = [cellInfo objectForKey:@"status"];
    if ([status isEqualToString:IncidentStatusNewString]) {
        // New
        cell.iconImage.image = [UIImage imageNamed:@"new_icon.png"];
        cell.incidentStatusLabel.text = IncidentStatusNewString;
    }
    else if ([status isEqualToString:IncidentStatusActiveString]) {
        // Active
        cell.iconImage.image = [UIImage imageNamed:@"active_icon.png"];
        cell.incidentStatusLabel.text = IncidentStatusActiveString;   
    }
    else if ([status isEqualToString:IncidentStatusClosedString]) {
        // Closed
        cell.iconImage.image = [UIImage imageNamed:@"closed_icon.png"];
        cell.incidentStatusLabel.text = IncidentStatusClosedString;
    }
    else {
        // Pending
        cell.iconImage.image = [UIImage imageNamed:@"pending_icon.png"];
        cell.incidentStatusLabel.text = IncidentStatusPendingString;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        return kIncidentsTableCellheight;
    }
	return kIncidentsTableCellheightP;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deal with the selection
	int row = [indexPath row];
    BCMSIncidentDetailsController *incidentDetailsController = [[BCMSIncidentDetailsController alloc] initWithNibName:nil bundle:nil];
    incidentDetailsController.incidentId = row;
    [BCMSHelper postNotification:PushViewNotification param:incidentDetailsController];
    [tableView reloadData];
}

@end
