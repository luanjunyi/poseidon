//
//  BCMSMoreListsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMoreListsController.h"
#import "BCMSHelper.h"
#import "BCMSContactListExpandedController.h"
#import "BCMSOptionsTableCell.h"
#import "BCMSMoreDetailsController.h"

@implementation BCMSMoreListsController
@synthesize titleLabel;
@synthesize  moreListType;
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
    tableList = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"more"] objectAtIndex:moreListType] objectForKey:@"items"];
    titleLabel.text = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"more"] objectAtIndex:moreListType] objectForKey:@"name"];
    
    if (theTableView == nil) {
        if (moreListType == 0) {
            self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 48, 480, 272) style:UITableViewStylePlain];
        }
        else {
            self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 48, 480, 272) style:UITableViewStyleGrouped];
        }
        self.theTableView.delegate = self;
        self.theTableView.dataSource = self;
        [theTableView setSectionFooterHeight:0.0];
        [theTableView setSectionHeaderHeight:10.0];
        [theTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:theTableView];
    }
    [self doLayout:self.interfaceOrientation];
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
        self.theTableView.frame = CGRectMake(0, 48, 480, 272);
    }
    else {
        self.theTableView.frame = CGRectMake(0, 48, 320, 432);
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
    
    if (moreListType == 0) {
        // Use customized cell
        BCMSOptionsTableCell *cell = (BCMSOptionsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Fill the cell properties.
        cell.cellTitle.text = [[tableList objectAtIndex:section] objectForKey:@"name"];
        cell.optionsLabel.hidden = YES;
        [cell.cellTitle setShadowOffset:CGSizeMake(0, 1)];
        [cell.optionsLabel setShadowOffset:CGSizeMake(0, 1)];
        cell.cellSeparator.hidden = NO;
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;
    }
    else {
        // Use customized cell
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] init];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
        cell.textLabel.text = [[tableList objectAtIndex:section] objectForKey:@"name"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kMoreTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Load the more details view.
    NSUInteger section = [indexPath section];
    BCMSMoreDetailsController *moreDetailsController = [[BCMSMoreDetailsController alloc] initWithNibName:nil bundle:nil];
    moreDetailsController.moreDetailsIndex = section;
    moreDetailsController.moreListType = moreListType;
    [BCMSHelper postNotification:PushViewNotification param:moreDetailsController];
}

@end
