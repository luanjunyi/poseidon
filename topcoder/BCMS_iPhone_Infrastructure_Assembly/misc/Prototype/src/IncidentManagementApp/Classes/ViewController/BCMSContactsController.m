//
//  BCMSContactsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSContactsController.h"
#import "BCMSHelper.h"
#import "BCMSContactListsController.h"
#import "BCMSDirectReportsController.h"

@implementation BCMSContactsController
@synthesize titleLabel;

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
    tableList = [[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"contacts"];
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

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender {
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
    
    // Fill cell properties.
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
    NSUInteger section = [indexPath section];
    
    // Show different views according to the selection
    if (section == 0 || section == 1) {
        BCMSContactListsController *contactListsController = [[BCMSContactListsController alloc] initWithNibName:nil bundle:nil];
        contactListsController.contactListType = section;
        [BCMSHelper postNotification:PushViewNotification param:contactListsController];
    }
    else {
        BCMSDirectReportsController *reportsController = [[BCMSDirectReportsController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:reportsController];        
    }
}

@end
