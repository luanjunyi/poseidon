//
//  BCMSContactListsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSContactListsController.h"
#import "BCMSHelper.h"
#import "BCMSContactListExpandedController.h"

@implementation BCMSContactListsController
@synthesize titleLabel;
@synthesize contactListType;

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
    tableList = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"contacts"] objectAtIndex:contactListType] objectForKey:@"items"];
    titleLabel.text = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"contacts"] objectAtIndex:contactListType] objectForKey:@"name"];
}

// Unload
- (void)viewDidUnload
{
    self.titleLabel = nil;
    [super viewDidUnload];
}

// Return YES for supported orientations
// Params:
//      interfaceOrientation: The orientation
// Return: YES for supported orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"NormalContactsTableCellIdentifier";
    
    // Prepare cell information
    NSUInteger section = [indexPath section];
    
	// Use customized cell
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] init];
	}
    
    // Fill the cell properties.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    cell.textLabel.text = [[tableList objectAtIndex:section] objectForKey:@"name"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kContactsTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show the contact list expanded view.
    NSUInteger section = [indexPath section];
    BCMSContactListExpandedController *contactListExpandedController = [[BCMSContactListExpandedController alloc] initWithNibName:nil bundle:nil];
    contactListExpandedController.tableInfo = [tableList objectAtIndex:section];
    [BCMSHelper postNotification:PushViewNotification param:contactListExpandedController];
}

@end
