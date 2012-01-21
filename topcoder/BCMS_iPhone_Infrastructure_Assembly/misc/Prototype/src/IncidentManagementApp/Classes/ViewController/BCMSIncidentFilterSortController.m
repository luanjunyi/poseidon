//
//  BCMSIncidentFilterSortController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSIncidentFilterSortController.h"
#import "BCMSOptionsTableCell.h"
#import "BCMSHelper.h"
#import "BCMSIncidentOptionsController.h"

@implementation BCMSIncidentFilterSortController
@synthesize optionsListView;

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
    optionsList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"filterSortOptions"] objectForKey:@"items"];
}

// Unload
- (void)viewDidUnload
{
    self.optionsListView = nil;
    [super viewDidUnload];
}

// Called when view will appear. This is a delegate.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [optionsListView reloadData];
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
    [optionsListView reloadData];
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
	return [optionsList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *cellIdentifier = @"OptionsListCellIdentifier";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [optionsList objectAtIndex:row];
    
	// Use customized cell
	BCMSOptionsTableCell *cell = (BCMSOptionsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}

    cell.cellTitle.text = [cellInfo objectForKey:@"title"];
    // Multiple choice
    NSArray *options = [cellInfo objectForKey:@"options"];
    NSMutableString *optionsString = nil;
    if (options != nil && [options count] >= 1) {
        for (int i = 0; i < [options count]; i++) {
            NSDictionary *optionItem = [options objectAtIndex:i];
            if ([[optionItem objectForKey:@"selected"] boolValue]) {
                if (optionsString == nil) {
                    optionsString = [NSMutableString stringWithString:[optionItem objectForKey:@"name"]];
                }
                else {
                    optionsString = [NSMutableString stringWithFormat:@"%@,%@",optionsString,[optionItem objectForKey:@"name"]];
                }
            }
        }
    }
    cell.optionsLabel.text = optionsString;
    if(UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cell.optionsLabel setFrame:CGRectMake(180, 0, 250, 43)];
    }
    else {
        [cell.optionsLabel setFrame:CGRectMake(150, 0, 120, 43)];
    }
    [cell.optionsLabel setNumberOfLines:1];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kOptionsTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deal with the selection
	int row = [indexPath row];
    BCMSIncidentOptionsController *optionsController = [[BCMSIncidentOptionsController alloc] initWithNibName:nil bundle:nil];
    optionsController.listType = row;
    [BCMSHelper postNotification:PushViewNotification param:optionsController];    
}

@end
