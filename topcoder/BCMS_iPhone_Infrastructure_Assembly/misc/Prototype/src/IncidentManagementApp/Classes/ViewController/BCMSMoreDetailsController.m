//
//  BCMSMoreDetailsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSMoreDetailsController.h"
#import "BCMSMoreDetailsTableCell.h"
#import "BCMSHelper.h"

@implementation BCMSMoreDetailsController
@synthesize titleLabel;
@synthesize moreListType;
@synthesize moreDetailsIndex;
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
    NSDictionary *moreDetailsDict = [[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"more"] objectAtIndex:moreListType] objectForKey:@"items"] objectAtIndex:moreDetailsIndex];
    self.titleLabel.text = [moreDetailsDict objectForKey:@"name"];
    tableList = [moreDetailsDict objectForKey:@"people"];
}

// Unload
- (void)viewDidUnload
{
    self.titleLabel = nil;
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
	NSString *cellIdentifier = @"MoreDetailsTableCellIdentifier";
    
    // Prepare cell information
    NSUInteger row = [indexPath row];
    
    // Use customized cell
    BCMSMoreDetailsTableCell *cell = (BCMSMoreDetailsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSMoreDetailsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Fill cell properties.
    NSDictionary *cellInfo = [tableList objectAtIndex:row];
    cell.nameLabel.text = [cellInfo objectForKey:@"name"];
    cell.jobLabel.text = [cellInfo objectForKey:@"occupation"];
    cell.primaryLabel.text = [cellInfo objectForKey:@"primary"];
    cell.secondaryLabel.text = [cellInfo objectForKey:@"secondary"];
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cell.primaryContactLabel setFrame:CGRectMake(60, 51, 166, 34)];
        [cell.secondaryContactLabel setFrame:CGRectMake(60, 104, 166, 34)];
        [cell.primaryContactLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [cell.secondaryContactLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
    else {
        [cell.primaryContactLabel setFrame:CGRectMake(60, 51, 106, 34)];
        [cell.secondaryContactLabel setFrame:CGRectMake(60, 104, 106, 34)];
        [cell.primaryContactLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [cell.secondaryContactLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kMoreDetailsTableCellheight;
}

@end
