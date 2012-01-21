//
//  BCMSChecklistController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSChecklistController.h"
#import "BCMSHelper.h"
#import "BCMSOptionsTableCell2.h"

@implementation BCMSChecklistController
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
    checkList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"checklistForm"];
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

// Called when clicked the checkbox
// Params:
//      sender: The sender of the action
- (IBAction)checkboxClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag > 0) {
        [button setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    }
    
    button.tag = -button.tag;
}

// Called when clicked the close button
// Params:
//      sender: The sender of the action
- (IBAction)closeClicked:(id)sender {
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
	return [checkList count];
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"OptionsListCellIdentifier2";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [checkList objectAtIndex:row];
    
	// Use customized cell
	BCMSOptionsTableCell2 *cell = (BCMSOptionsTableCell2 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell2" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    cell.cellTitle.text = [NSString stringWithFormat:@"%d. %@",(row+1),[cellInfo objectForKey:@"title"]];
    
    // Remove the existing checkboxes
    NSArray *childViews = [cell subviews];
    for (int i = 0; i < [childViews count]; i++) {
        UIView *childView = [childViews objectAtIndex:i];
        if (childView.tag != 0) {
            [childView removeFromSuperview];
        }
    }
    
    int xStart = 35;
    int yStart = 35;
    for (int i = 0; i < [[cellInfo objectForKey:@"items"] count]; i++) {
        // Add a checkbox
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xStart, yStart, 32, 32)];
        [button setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        [cell addSubview:button];
        
        // Add a label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xStart + 45, yStart, 180, 32)];
        label.text = [[cellInfo objectForKey:@"items"] objectAtIndex:i];
        label.tag = -1;
        [label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [label setShadowColor:[UIColor whiteColor]];
        [label setShadowOffset:CGSizeMake(0, 1)];
        [label setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:label];
        if (i % 2 == 0 && UIInterfaceOrientationIsLandscape(myOrientation)) {
            xStart += 220;
        }
        else {
            xStart = 35;
            yStart += 40;
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Calculate the cell height
    NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [checkList objectAtIndex:row];
    int nItems = [[cellInfo objectForKey:@"items"] count];
    int cellHeight;
    
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        cellHeight = (nItems + 1)/2 * 35 + 50;
    }
    else {
        cellHeight = (nItems + 1) * 35 + 50;
    }
    
	return cellHeight;
}

@end
