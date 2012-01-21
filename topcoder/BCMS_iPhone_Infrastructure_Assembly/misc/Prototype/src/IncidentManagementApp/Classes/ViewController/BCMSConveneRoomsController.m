//
//  BCMSConveneRoomsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSConveneRoomsController.h"
#import "BCMSHelper.h"
#import "BCMSConveneRoomsTableCell.h"
#import "BCMSAddConvenRoomController.h"

@implementation BCMSConveneRoomsController
@synthesize deleteButton;
@synthesize roomsTableView;
@synthesize noticeView;
@synthesize notificationBgView;
@synthesize notificationBg;

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
    tableList = [[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"conveneRooms"];
    showDelete = NO;
}

// Unload
- (void)viewDidUnload
{
    self.deleteButton = nil;
    self.roomsTableView = nil;
    self.noticeView = nil;
    self.notificationBgView = nil;
    self.notificationBg = nil;
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

// Called when clicked the delete button
// Params:
//      sender: The sender of the action
- (IBAction)deleteClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == -1) {
        // Clicked the delete button at the top
        showDelete = !showDelete;
        if (showDelete) {
            [deleteButton setImage:[UIImage imageNamed:@"delete_button_highlight.png"] forState:UIControlStateNormal];
        }
        else {
            [deleteButton setImage:[UIImage imageNamed:@"red_delete_button.png"] forState:UIControlStateNormal];
        }
        [roomsTableView reloadData];        
    }
    else {
        [BCMSHelper fadeViewIn:noticeView parentView:self.view];
    }
}

// Called when clicked the add button
// Params:
//      sender: The sender of the action
- (IBAction)addClicked:(id)sender {
    BCMSAddConvenRoomController *addRoomViewController = [[BCMSAddConvenRoomController alloc] initWithNibName:nil bundle:nil];
    [BCMSHelper postNotification:PushViewNotification param:addRoomViewController];
}

// Called when clicked the YES button
// Params:
//      sender: The sender of the action
- (IBAction)yesClicked:(id)sender {
    [BCMSHelper fadeViewOut:noticeView parentView:self.view];
}

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender {
    [BCMSHelper fadeViewOut:noticeView parentView:self.view];
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [notificationBgView setFrame:CGRectMake(20, 51, 440, 140)];
    }
    else {
        [notificationBgView setFrame:CGRectMake(10, 140, 300, 140)];
    }
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
	NSString *cellIdentifier = @"NormalMoreTableCellIdentifier";
    
    // Prepare cell information
    NSUInteger section = [indexPath section];
    
	// Use customized cell
	BCMSConveneRoomsTableCell *cell = (BCMSConveneRoomsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSConveneRoomsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Fill the cell properties.
    cell.nameLabel.text = [[tableList objectAtIndex:section] objectForKey:@"name"];
    cell.officeLabel.text = [[tableList objectAtIndex:section] objectForKey:@"office"];
    if (showDelete) {
        [cell.deleteButton setHidden:NO];
        cell.deleteButton.tag = section;
        [cell.deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [cell.deleteButton setHidden:YES];
    }

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kConveneRoomsTableCellheight;
}

@end
