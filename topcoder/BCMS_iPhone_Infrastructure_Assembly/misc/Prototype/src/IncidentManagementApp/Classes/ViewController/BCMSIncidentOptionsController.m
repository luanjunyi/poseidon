//
//  BCMSIncidentOptionsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSIncidentOptionsController.h"
#import "BCMSOptionsTableCell2.h"
#import "BCMSHelper.h"

@implementation BCMSIncidentOptionsController
@synthesize listType;
@synthesize optionsTableView;
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
    optionsList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"filterSortOptions"] objectForKey:@"items"];
    if (optionsTableView == nil) {
        if (listType == kListTypeSort) {
            optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 480, 270) style:UITableViewStyleGrouped];
        }
        else {
            optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 480, 270) style:UITableViewStylePlain];
        }
        optionsTableView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        optionsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:optionsTableView];
        optionsTableView.delegate = self;
        optionsTableView.dataSource = self;
        [self doLayout:self.interfaceOrientation];
    }
    self.titleLabel.text = [[optionsList objectAtIndex:listType] objectForKey:@"title"];
    
    // Prepare the grouped list
    groupedCountryList = [[NSMutableDictionary alloc] init];
    if (listType == kListTypeLocations) {
        NSMutableArray *countryList = [[optionsList objectAtIndex:listType] objectForKey:@"options"];
        // Fill in the grouped list
        for (int i = 0; i < [countryList count]; i++) {
            NSMutableDictionary *item = [countryList objectAtIndex:i];       
            // Make groups
            NSString *groupName = [[item objectForKey:@"name"] substringToIndex:1];
            NSArray *keys = [groupedCountryList allKeys];
            BOOL keyExist = NO;
            for (int j = 0; j < [keys count]; j++) {
                if ([groupName isEqualToString:[keys objectAtIndex:j]]) {
                    keyExist = YES;
                    break;
                }
            }
            
            NSMutableArray *groupArray = nil;
            if (keyExist) {
                groupArray = [groupedCountryList objectForKey:groupName];
            }
            else {
                groupArray = [NSMutableArray array];
            }
            
            [groupArray addObject:item];
            [groupedCountryList setObject:groupArray forKey:groupName];
        }
    }
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
        [optionsTableView setFrame:CGRectMake(0, 50, 480, 270)];
    }
    else {
        [optionsTableView setFrame:CGRectMake(0, 50, 320, 430)];
    }
    [optionsTableView reloadData];
}

#pragma mark -
#pragma mark Table Data Source Methods
// The following methods are standard table data source and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (listType == kListTypeLocations) {
        return [[groupedCountryList allKeys] count];
    }
    
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    if (listType == kListTypeLocations) {
        NSMutableArray *listInGroup = [groupedCountryList objectForKey:[[groupedCountryList allKeys] objectAtIndex:section]];
        return [listInGroup count];
    }
	return [[[optionsList objectAtIndex:listType] objectForKey:@"options"] count];
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    if (listType == kListTypeLocations) {
        return [[groupedCountryList allKeys] objectAtIndex:section];
    }
	return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *cellIdentifier = @"OptionsListCellIdentifier2";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
	NSDictionary *cellInfo = nil;
    
    if (listType == kListTypeStatus || listType == kListTypeSort) {
        cellInfo = [[[optionsList objectAtIndex:listType] objectForKey:@"options"] objectAtIndex:row];
    }
    else {
        cellInfo = [[groupedCountryList objectForKey:[[groupedCountryList allKeys] objectAtIndex:section]] objectAtIndex:row];
    }
    
	// Use customized cell
	BCMSOptionsTableCell2 *cell = (BCMSOptionsTableCell2 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell2" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}

    cell.cellTitle.text = [cellInfo objectForKey:@"name"];
    
    if (listType == kListTypeSort) {
        cell.separatorImage.hidden = YES;
    }
    else {
        cell.separatorImage.hidden = NO;
    }
    
    BOOL selected = [[cellInfo objectForKey:@"selected"] boolValue];
    if (selected) {
        if (listType == kListTypeStatus || listType == kListTypeLocations) {
            cell.selectionImage.image = [UIImage imageNamed:@"checkbox_checked.png"];
        }
        else {
            cell.selectionImage.image = [UIImage imageNamed:@"tickmark.png"];
        }
        cell.cellTitle.textColor = kBlueColor;
    }
    else {
        if (listType == kListTypeStatus || listType == kListTypeLocations) {
            cell.selectionImage.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
        }
        else {
            cell.selectionImage.image = nil;
        }
        cell.cellTitle.textColor = [UIColor blackColor];
    }
    
	return cell;
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
    int section = [indexPath section];
    if (listType == kListTypeSort) {
        // Only allow single choice
        NSMutableArray *listArray = [[optionsList objectAtIndex:listType] objectForKey:@"options"];
        for (int i = 0; i < [listArray count]; i++) {
            NSMutableDictionary *item = [listArray objectAtIndex:i];
            if (i == row) {
                [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            }
            else {
                [item setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            }
        }
    }
    else if (listType == kListTypeStatus) {
        // Allow multiple choice
        NSMutableDictionary *cellInfo = [[[optionsList objectAtIndex:listType] objectForKey:@"options"] objectAtIndex:row];
        BOOL selected = [[cellInfo objectForKey:@"selected"] boolValue];
        selected = !selected;
        [cellInfo setObject:[NSNumber numberWithBool:selected] forKey:@"selected"];
    }
    else {
        NSMutableArray *listInGroup = [groupedCountryList objectForKey:[[groupedCountryList allKeys] objectAtIndex:section]];
        NSMutableDictionary *cellInfo = [listInGroup objectAtIndex:row];
        BOOL selected = [[cellInfo objectForKey:@"selected"] boolValue];
        selected = !selected;
        [cellInfo setObject:[NSNumber numberWithBool:selected] forKey:@"selected"];
    }
    [tableView reloadData];
}

@end
