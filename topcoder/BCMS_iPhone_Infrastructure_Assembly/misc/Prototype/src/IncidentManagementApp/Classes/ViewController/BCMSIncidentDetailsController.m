//
//  BCMSIncidentDetailsController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSIncidentDetailsController.h"
#import "BCMSHelper.h"
#import "BCMSOptionsTableCell.h"
#import "BCMSChecklistController.h"
#import "BCMSNotesViewController.h"
#import "BCMSUpdateIncidentController.h"

@implementation BCMSIncidentDetailsController
@synthesize incidentId;
@synthesize menuButton;
@synthesize headerLabel;
@synthesize functionsView;
@synthesize theTableView;
@synthesize gotoTopButton;
@synthesize scrollView;
@synthesize notificationBg;
@synthesize checkListButton;
@synthesize noteButton;
@synthesize attachmentsButton;
@synthesize updateButton;

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
    tableList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"detailsForm"];
    incidentInfo = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId];
    [menuButton setImage:[UIImage imageNamed:@"blue_button_pressed.png"] forState:UIControlStateHighlighted];
    headerLabel.text = [incidentInfo objectForKey:@"title"];
    
    groupHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    [groupHeaderView setBackgroundColor:[UIColor clearColor]];
    groupHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 25)];
    groupHeaderLabel.font = [UIFont boldSystemFontOfSize:17.0];
    groupHeaderLabel.backgroundColor = [UIColor clearColor];
    [groupHeaderLabel setShadowColor:[UIColor whiteColor]];
    [groupHeaderLabel setShadowOffset:CGSizeMake(0, 1)];
    [groupHeaderView addSubview:groupHeaderLabel];
    [self doLayout:self.interfaceOrientation];
}

// Unload
- (void)viewDidUnload
{
    self.menuButton = nil;
    self.headerLabel = nil;
    self.functionsView = nil;
    self.theTableView = nil;
    self.gotoTopButton = nil;
    self.scrollView = nil;
    self.checkListButton = nil;
    self.noteButton = nil;
    self.attachmentsButton = nil;
    self.updateButton = nil;
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

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender {
    [BCMSHelper postNotification:PopViewNotification param:nil];
}

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender {
    if (functionsView.alpha == 0.0) {
        [menuButton setImage:[UIImage imageNamed:@"blue_button_pressed.png"] forState:UIControlStateNormal];
        [BCMSHelper fadeViewIn:functionsView parentView:self.view];
    }
    else {
        [menuButton setImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
        [BCMSHelper fadeViewOut:functionsView parentView:self.view];
    }
}

// Called when clicked the menu buttons
// Params:
//      sender: The sender of the action
- (IBAction)menuButtonsClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        // Checklist view
        BCMSChecklistController *checklistController = [[BCMSChecklistController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:checklistController];
    }
    else if (button.tag == 1) {
        // Notes view
        BCMSNotesViewController *notesViewController = [[BCMSNotesViewController alloc] initWithNibName:nil bundle:nil];
        [BCMSHelper postNotification:PushViewNotification param:notesViewController];
    }
    else if (button.tag == 2) {
        // Update view
        BCMSUpdateIncidentController *updateViewController = [[BCMSUpdateIncidentController alloc] initWithNibName:nil bundle:nil];
        updateViewController.incidentId = incidentId;
        [BCMSHelper postNotification:PushViewNotification param:updateViewController];
    }
}

// Called when clicked the goto top button
// Params:
//      sender: The sender of the action
- (IBAction)gotoTopButtonsClicked:(id)sender {
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 5, 5) animated:YES];
}

// Setup the content size of the scroll view
- (void)setupScrollView {
    CGRect tableFrame = theTableView.frame;
    tableFrame.size.height = theTableView.contentSize.height;
    [theTableView setFrame:tableFrame];
    
    scrollView.contentSize = CGSizeMake(theTableView.frame.size.width, theTableView.frame.size.height + 40);
    [gotoTopButton setFrame:CGRectMake(20, theTableView.frame.size.height + 5, 70, 20)];
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    myOrientation = orientation;
    [theTableView reloadData];
    [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.1];
    
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        [checkListButton setFrame:CGRectMake(93, 33, 293, 47)];
        [noteButton setFrame:CGRectMake(93, 85, 293, 47)];
        [attachmentsButton setFrame:CGRectMake(93, 137, 293, 47)];
        [updateButton setFrame:CGRectMake(93, 189, 293, 47)];
        [checkListButton setImage:[UIImage imageNamed:@"checklist_button.png"] forState:UIControlStateNormal];
        [noteButton setImage:[UIImage imageNamed:@"note_button.png"] forState:UIControlStateNormal];
        [attachmentsButton setImage:[UIImage imageNamed:@"attachments_button.png"] forState:UIControlStateNormal];
        [updateButton setImage:[UIImage imageNamed:@"update_button.png"] forState:UIControlStateNormal];
        [notificationBg setFrame:CGRectMake(20, 26, 440, 220)];
        [notificationBg setImage:[UIImage imageNamed:@"detail_menu_bg.png"]];
    }
    else {
        [checkListButton setFrame:CGRectMake(24, 109, 273, 47)];
        [noteButton setFrame:CGRectMake(24, 161, 273, 47)];
        [attachmentsButton setFrame:CGRectMake(24, 213, 273, 47)];
        [updateButton setFrame:CGRectMake(24, 265, 273, 47)];
        [checkListButton setImage:[UIImage imageNamed:@"checklist_button_p.png"] forState:UIControlStateNormal];
        [noteButton setImage:[UIImage imageNamed:@"note_button_p.png"] forState:UIControlStateNormal];
        [attachmentsButton setImage:[UIImage imageNamed:@"attachments_button_p.png"] forState:UIControlStateNormal];
        [updateButton setImage:[UIImage imageNamed:@"update_button_p.png"] forState:UIControlStateNormal];
        [notificationBg setFrame:CGRectMake(10, 101, 300, 220)];
        [notificationBg setImage:[UIImage imageNamed:@"detail_menu_bg_p.png"]];
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
	return [[[tableList objectAtIndex:section] objectForKey:@"items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *tableItem = [tableList objectAtIndex:section];
    if ([[tableItem objectForKey:@"showHeader"] boolValue]) {
        return 25;
    }
	return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *tableItem = [tableList objectAtIndex:section];
    if ([[tableItem objectForKey:@"showHeader"] boolValue]) {
        groupHeaderLabel.text = [tableItem objectForKey:@"header"];
        return groupHeaderView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"OptionsListCellIdentifier";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
	NSDictionary *cellInfo = [[[tableList objectAtIndex:section] objectForKey:@"items"] objectAtIndex:row];
    
	// Use customized cell
	BCMSOptionsTableCell *cell = (BCMSOptionsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSOptionsTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    cell.cellTitle.text = [cellInfo objectForKey:@"title"];
    [cell.cellTitle setFont:[UIFont boldSystemFontOfSize:18]];
    [cell.optionsLabel setFont:[UIFont systemFontOfSize:16]];
    if(UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cell.optionsLabel setFrame:CGRectMake(298, 0, 150, 43)];
    }
    else {
        [cell.optionsLabel setFrame:CGRectMake(170, 0, 120, 43)];
    }
    
    // Clean up the cell first
    NSArray *subViews = [cell subviews];
    for (int i = 0; i < [subViews count]; i++) {
        UIView *subView = [subViews objectAtIndex:i];
        if (subView.tag == -1) {
            [subView removeFromSuperview];
        }
    }
    int type = [[cellInfo objectForKey:@"type"] intValue];
    id value = [incidentInfo objectForKey:[cellInfo objectForKey:@"name"]];
    if (type == 0) {
        cell.optionsLabel.text = value;
    }
    else if (type == 1) {
        cell.optionsLabel.text = [value capitalizedString];
        
        // Show the icon
        UIImageView *iconView = nil;
        for (int i = 0; i < [[cell subviews] count]; i++) {
            if ([[[cell subviews] objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
                iconView = [[cell subviews] objectAtIndex:i];
                break;
            }
        }
        if (iconView == nil) {
            iconView = [[UIImageView alloc] initWithFrame:CGRectMake(430, 7, 30, 30)];
            iconView.tag = -1;
            [cell addSubview:iconView];
        }
        if (UIInterfaceOrientationIsLandscape(myOrientation)) {
            iconView.frame = CGRectMake(430, 7, 30, 30);
            [cell.optionsLabel setFrame:CGRectMake(350, 10, 60, 24)];
        }
        else {
            iconView.frame = CGRectMake(270, 7, 30, 30); 
            [cell.optionsLabel setFrame:CGRectMake(190, 10, 60, 24)];
        }
        
        if ([value isEqualToString:@"NEW"]) {
            iconView.image = [UIImage imageNamed:@"new_icon.png"];
        }
        else if ([value isEqualToString:@"ACTIVE"]) {
            iconView.image = [UIImage imageNamed:@"active_icon.png"];
        }
        else if ([value isEqualToString:@"PENDING"]) {
            iconView.image = [UIImage imageNamed:@"pending_icon.png"];
        }
        else {
            iconView.image = [UIImage imageNamed:@"closed_icon.png"];
        }
        [iconView setHidden:NO];
    }
    else if (type == 2) {
        // Date
        if(UIInterfaceOrientationIsLandscape(myOrientation)) {
            [cell.optionsLabel setFont:[UIFont systemFontOfSize:16]];
            [cell.optionsLabel setFrame:CGRectMake(228, 0, 220, 43)];
            cell.optionsLabel.text = [BCMSHelper convertDateToStringFormat2:value];
        }
        else {
            [cell.optionsLabel setFont:[UIFont systemFontOfSize:10]];
            [cell.optionsLabel setFrame:CGRectMake(210, 0, 80, 43)];
            cell.optionsLabel.text = [BCMSHelper convertDateToStringFormat3:value];
        }
    }
    else if (type == 3) {
        // Details
        UILabel *detailsLabel = [[UILabel alloc] init];
        [BCMSHelper setupDetailsLabel:detailsLabel text:value orientation:myOrientation];
        [cell addSubview:detailsLabel];
        cell.optionsLabel.text = @"";
    }
    else if (type == 4) {
        // Comments
        UILabel *commentLabel = [[UILabel alloc] init];
        NSString *comment = [value objectAtIndex:row];
        [BCMSHelper setupDetailsLabel:commentLabel text:comment orientation:myOrientation];
        [cell addSubview:commentLabel];
        cell.optionsLabel.text = @"";
        [cell.cellTitle setFont:[UIFont boldSystemFontOfSize:14]];
    }
    else if (type == 5) {
        // ISM owner
        UILabel *ownerLabel = [[UILabel alloc] init];
        [BCMSHelper setupDetailsLabel:ownerLabel text:value orientation:myOrientation];
        [cell addSubview:ownerLabel];
        cell.optionsLabel.text = @"";
        
        // Add a phone button and label
        UIButton *phoneButton = [[UIButton alloc] init];
        phoneButton.tag = -1;
        [phoneButton setImage:[UIImage imageNamed:@"phone_button.png"] forState:UIControlStateNormal];
        if (UIInterfaceOrientationIsLandscape(myOrientation)) {
            [phoneButton setFrame:CGRectMake(370, 17, 90, 37)];
        }
        else {
            [phoneButton setFrame:CGRectMake(210, 17, 90, 37)];
        }
        [cell addSubview:phoneButton];
        
        UILabel *phoneLabel = [[UILabel alloc] init];
        phoneLabel.tag = -1;
        phoneLabel.backgroundColor = [UIColor clearColor];
        phoneLabel.text = [incidentInfo objectForKey:@"phone"];
        phoneLabel.font = [UIFont systemFontOfSize:11];
        phoneLabel.textAlignment = UITextAlignmentCenter;
        phoneLabel.shadowOffset = CGSizeMake(0, 1);
        phoneLabel.shadowColor = [UIColor whiteColor];
        if (UIInterfaceOrientationIsLandscape(myOrientation)) {
            [phoneLabel setFrame:CGRectMake(370, 31, 90, 17)];
        }
        else {
            [phoneLabel setFrame:CGRectMake(210, 31, 90, 17)];
        }
        [cell addSubview:phoneLabel];
    }
    else if (type == 6) {
        // Outages
        cell.cellTitle.text = @"";
        cell.optionsLabel.text = @"";
        
        // Add a selection button and a label
        UIButton *selectionButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, 28, 28)];
        selectionButton.tag = -1;
        BOOL selected = [[[incidentInfo objectForKey:@"outages"] objectAtIndex:row] boolValue];
        if (selected) {
            [selectionButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];                    
        }
        else {
            [selectionButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        }
        
        [cell addSubview:selectionButton];
        
        UILabel *selectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 8, 250, 28)];
        selectionLabel.tag = -1;
        selectionLabel.backgroundColor = [UIColor clearColor];
        selectionLabel.text = [cellInfo objectForKey:@"title"];
        selectionLabel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:selectionLabel];
    }
    
    [cell.cellTitle.text capitalizedString];

    cell.accessoryIcon.hidden = YES;
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
	NSDictionary *cellInfo = [[[tableList objectAtIndex:section] objectForKey:@"items"] objectAtIndex:row];
    int type = [[cellInfo objectForKey:@"type"] intValue];
    if (type == 3 || type == 5) {
        CGRect detailsLabelFrame = [BCMSHelper calculateDetailsLabelFrame:[incidentInfo objectForKey:[cellInfo objectForKey:@"name"]] orientation:myOrientation];
        return detailsLabelFrame.origin.y + detailsLabelFrame.size.height + 10;
    }
    else if (type == 4) {
        NSString *comment = [[incidentInfo objectForKey:[cellInfo objectForKey:@"name"]] objectAtIndex:row];
        CGRect commentLabelFrame = [BCMSHelper calculateDetailsLabelFrame:comment orientation:myOrientation];
        return commentLabelFrame.origin.y + commentLabelFrame.size.height + 10;
    }
	return kTableCellheight;
}

@end
