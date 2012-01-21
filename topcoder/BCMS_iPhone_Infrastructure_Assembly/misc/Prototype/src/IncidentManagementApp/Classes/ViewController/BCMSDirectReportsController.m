//
//  BCMSDirectReportsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSDirectReportsController.h"
#import "BCMSHelper.h"
#import "BCMSDirectReportsTableCell.h"
#import "BCMSReportsDetailController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCMSDirectReportsController
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
    tableList = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"contacts"] objectAtIndex:2] objectForKey:@"items"];
    for (int i = 0; i < [tableList count]; i++) {
        selectionArray[i] = NO;
    }
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

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the item in the cell
// Params:
//      sender: The sender of the action
- (IBAction)itemClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    BCMSReportsDetailController *detailController = [[BCMSReportsDetailController alloc] initWithNibName:nil bundle:nil];
    detailController.reportId = button.tag / kMaxRows;
    detailController.personId = button.tag % kMaxRows;
    [BCMSHelper postNotification:PushViewNotification param:detailController];
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
	NSString *cellIdentifier = @"DirectReportsCellIdentifier";
    
    // Prepare cell information
    NSUInteger row = [indexPath row];
    
	// Use customized cell
	BCMSDirectReportsTableCell *cell = (BCMSDirectReportsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSDirectReportsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    cell.reportName.text = [[tableList objectAtIndex:row] objectForKey:@"name"];
    
    if (!selectionArray[row]) {
        cell.iconImage.image = [UIImage imageNamed:@"blue_arrow.png"];
        cell.dropdownView.hidden = YES;
    }
    else {
        cell.iconImage.image = [UIImage imageNamed:@"blue_arrow_down.png"];
        cell.dropdownView.hidden = NO;
        cell.dropdownView.layer.borderColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
        cell.dropdownView.layer.borderWidth = 1.0;
        [cell.dropdownView.layer setCornerRadius:10.0];
        // Clean up the view
        NSArray *childViews = [cell.dropdownView subviews];
        for (int i = 0; i < [childViews count]; i++) {
            [[childViews objectAtIndex:i] removeFromSuperview];
        }
        
        int sizeOffset = 0;
        if (UIInterfaceOrientationIsPortrait(myOrientation)) {
            sizeOffset = -160;
        }
        
        int yStart = 53;
        for (int i = 0; i < [[[tableList objectAtIndex:row] objectForKey:@"items"] count]; i++) {
            NSDictionary *item = [[[tableList objectAtIndex:row] objectForKey:@"items"] objectAtIndex:i];
            
            // Add button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setFrame:CGRectMake(13, yStart, 428 + sizeOffset, 40)];
            button.tag = row * kMaxRows + i;
            [button addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.dropdownView addSubview:button];
            
            // Add labels
            UILabel *nameLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(25, yStart, 300 + sizeOffset, 40)];
            nameLabel1.text = @"Name:";
            [nameLabel1 setBackgroundColor:[UIColor clearColor]];
            [nameLabel1 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
            [cell.dropdownView addSubview:nameLabel1];
            
            UILabel *nameLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(75, yStart, 300 + sizeOffset, 40)];
            nameLabel2.text = [item objectForKey:@"name"];
            [nameLabel2 setBackgroundColor:[UIColor clearColor]];
            [nameLabel2 setFont:[UIFont fontWithName:@"Helvetica" size:16]];
            [cell.dropdownView addSubview:nameLabel2];
            yStart += 46;
        }
    }
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (!selectionArray[row]) {
        return kDirectReportsTableCellheight;
    }
    else {
        return kDirectReportsTableCellheight + [[[tableList objectAtIndex:row] objectForKey:@"items"] count] * 46 + 15;
    }
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    selectionArray[row] = !selectionArray[row];
    [tableView reloadData];
}
@end
