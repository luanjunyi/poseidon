//
//  BCMSMoreViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMoreViewController.h"
#import "BCMSHelper.h"
#import "BCMSMoreListsController.h"

@implementation BCMSMoreViewController

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
    tableList = [[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"more"];
}

// Unload
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	NSString *cellIdentifier = @"NormalMoreTableCellIdentifier";
    
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
	return kMoreTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show the More lists view.
    NSUInteger section = [indexPath section];
    BCMSMoreListsController *moreListsController = [[BCMSMoreListsController alloc] initWithNibName:nil bundle:nil];
    moreListsController.moreListType = section;
    [BCMSHelper postNotification:PushViewNotification param:moreListsController];
}

@end
