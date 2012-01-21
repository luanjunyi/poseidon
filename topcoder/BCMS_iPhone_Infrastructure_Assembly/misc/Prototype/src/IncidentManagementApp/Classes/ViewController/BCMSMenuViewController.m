//
//  BCMSMenuViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMenuViewController.h"
#import "BCMSMenuTableCell.h"
#import "BCMSHelper.h"
#import "BCMSIncidentsViewController.h"
#import "BCMSContactsController.h"
#import "BCMSMoreViewController.h"
#import "BCMSSettingsController.h"
#import "BCMSConveneRoomsController.h"

@implementation BCMSMenuViewController
@synthesize userInfoLabel;
@synthesize theTableView;
@synthesize wecomeLabel;

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
    menuList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"menu"] objectForKey:@"items"];
    userInfoLabel.text = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"menu"] objectForKey:@"userInfo"];
}

// Unload
- (void)viewDidUnload
{
    self.userInfoLabel = nil;
    self.theTableView = nil;
    self.wecomeLabel = nil;
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

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    myOrientation = orientation;
    [theTableView reloadData];
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        [wecomeLabel setFrame:CGRectMake(113, 49, 83, 29)];
        [userInfoLabel setFrame:CGRectMake(193, 49, 172, 29)];
    }
    else {
        [wecomeLabel setFrame:CGRectMake(33, 49, 83, 29)];
        [userInfoLabel setFrame:CGRectMake(113, 49, 172, 29)];
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
	return [menuList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *cellIdentifier = @"MenuListCellIdentifier";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [menuList objectAtIndex:row];
    
	// Use customized cell
	BCMSMenuTableCell *cell = (BCMSMenuTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSMenuTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    cell.cellTitle.text = [cellInfo objectForKey:@"title"];
    
    cell.imagePath = [cellInfo objectForKey:@"icon"];
    cell.imagePathHighlight = [cellInfo objectForKey:@"icon_highlighted"];
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cell.iconImage setFrame:CGRectMake(35, 3, 27, 30)];
        [cell.cellTitle setFrame:CGRectMake(82, 2, 316, 32)];
    }
    else {
        [cell.iconImage setFrame:CGRectMake(15, 8, 27, 30)];
        [cell.cellTitle setFrame:CGRectMake(62, 7, 316, 32)];
    }
    
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
        return kTableCellheight;
    }
	return kTableCellheightP;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
    
    // Deal with the selection
	int row = [indexPath row];
    if (row == 0) {
        // To Incidents view
        BCMSIncidentsViewController *incidentsViewController = [[BCMSIncidentsViewController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:incidentsViewController];
    }
    else if (row == 1) {
        // To Convene Rooms
        BCMSConveneRoomsController *conveneRoomsController = [[BCMSConveneRoomsController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:conveneRoomsController];
    }
    else if (row == 2) {
        // To Contacts view
        BCMSContactsController *contactsViewController = [[BCMSContactsController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:contactsViewController];
    }
    else if (row == 3) {
        // To More view
        BCMSMoreViewController *moreViewController = [[BCMSMoreViewController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:moreViewController];
    }
    else if (row == 4) {
        // To settings view
        BCMSSettingsController *settingsController = [[BCMSSettingsController alloc] initWithNibName:nil bundle:nil];
        settingsController.settingType = -1;
        [BCMSHelper postNotification:PushViewNotification param:settingsController];
    }
    else if (row == 5) {
        // To login view
        [BCMSHelper postNotification:PopViewNotification param:nil];
    }

}

@end
