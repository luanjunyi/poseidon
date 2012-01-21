//
//  BCMSUpdateIncidentController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSUpdateIncidentController.h"
#import "BCMSHelper.h"
#import "BCMSOptionsTableCell.h"

@implementation BCMSUpdateIncidentController
@synthesize scrollView;
@synthesize validationView;
@synthesize theTableView;
@synthesize incidentId;
@synthesize buttonsView;
@synthesize titleLabel;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize groupHeaderLabel;
@synthesize groupHeaderView;
@synthesize notificationBg;
@synthesize notificationTitle;
@synthesize notificationMessage;
@synthesize okButton;
@synthesize okLabel;
@synthesize tableContentView;

// Dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    tableList = [[[[BCMSHelper refreshDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"updateForm"];
    missingElements = [[NSMutableSet alloc] init];
    incidentInfo = [[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId];
    self.titleLabel.text = [incidentInfo objectForKey:@"title"];
    commentsArray = [[NSMutableArray alloc] init];
    
    [theTableView reloadData];
    
    groupHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    [groupHeaderView setBackgroundColor:[UIColor clearColor]];
    groupHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 25)];
    groupHeaderLabel.font = [UIFont boldSystemFontOfSize:17.0];
    groupHeaderLabel.backgroundColor = [UIColor clearColor];
    [groupHeaderLabel setShadowColor:[UIColor whiteColor]];
    [groupHeaderLabel setShadowOffset:CGSizeMake(0, 1)];
    [groupHeaderView addSubview:groupHeaderLabel];
    [self doLayout:self.interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

// Unload
- (void)viewDidUnload
{
    self.scrollView = nil;
    self.validationView = nil;
    self.theTableView = nil;
    self.buttonsView = nil;
    self.titleLabel = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
    self.groupHeaderLabel = nil;
    self.groupHeaderView = nil;
    self.notificationBg = nil;
    self.notificationTitle = nil;
    self.notificationMessage = nil;
    self.okButton = nil;
    self.okLabel = nil;
    self.tableContentView = nil;
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

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender {
    // Check if all required fields are filled.
    [missingElements removeAllObjects];
    for (int i = 0; i < [tableList count]; i++) {
        NSDictionary *dict = [tableList objectAtIndex:i];
        NSArray *items = [dict objectForKey:@"items"];
        for (int j = 0; j < [items count]; j++) {
            NSDictionary *item = [items objectAtIndex:j];
            if ([[item objectForKey:@"required"] boolValue]) {
                NSNumber *index = [NSNumber numberWithInt:i * 100 + j];
                id value = [incidentInfo objectForKey:[item objectForKey:@"name"]];
                if (value == nil || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@""])) {
                    [missingElements addObject:index];
                }
            }
        }
    }
    
    if ([missingElements count] > 0) {
        // There are missing elements.
        [theTableView reloadData];
        [BCMSHelper fadeViewIn:validationView parentView:self.view];
    }
    else {
        // In this assembly, simply return,
        [BCMSHelper postNotification:PopViewNotification param:nil];
    }
}

// Called when clicked the OK button
// Params:
//      sender: The sender of the action
- (IBAction)okClicked:(id)sender {
    [BCMSHelper fadeViewOut:validationView parentView:self.view];
}

// Called when clicked the outage button
// Params:
//      sender: The sender of the action
- (IBAction)outageButtonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == -1) {
        [button setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];                    
    }
    else {
        [button setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
    }
    button.tag = -button.tag;
}

// Setup the content size of the scroll view
- (void)setupScrollView {
    CGRect tableFrame = theTableView.frame;
    tableFrame.size.height = theTableView.contentSize.height;
    [theTableView setFrame:tableFrame];
    CGRect buttonsViewFrame = buttonsView.frame;
    buttonsViewFrame.origin.y = tableFrame.origin.y + tableFrame.size.height + 35;
    [buttonsView setFrame:buttonsViewFrame];
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(32, 8, 202, 52)];
        [doneButton setFrame:CGRectMake(246, 8, 202, 52)];
        [scrollView setContentSize:CGSizeMake(480, buttonsView.frame.origin.y + buttonsView.frame.size.height)];
    }
    else {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button_p.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button_p.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(14, 8, 142, 52)];
        [doneButton setFrame:CGRectMake(165, 8, 142, 52)];
        [scrollView setContentSize:CGSizeMake(320, buttonsView.frame.origin.y + buttonsView.frame.size.height)];
    }
}

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    myOrientation = orientation;
    [theTableView reloadData];
    [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.1];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(32, 8, 202, 52)];
        [doneButton setFrame:CGRectMake(246, 8, 202, 52)];
        [notificationBg setFrame:CGRectMake(62, 38, 355, 149)];
        [notificationBg setImage:[UIImage imageNamed:@"notification_bg2.png"]];
        [notificationTitle setFrame:CGRectMake(83, 46, 322, 28)];
        [notificationMessage setFrame:CGRectMake(71, 74, 347, 28)];
        [okLabel setFrame:CGRectMake(204, 134, 81, 28)];
        [okButton setFrame:CGRectMake(177, 124, 134, 47)];
    }
    else {
        [cancelButton setImage:[UIImage imageNamed:@"incident_cancel_button_p.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"add_done_button_p.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(14, 8, 142, 52)];
        [doneButton setFrame:CGRectMake(165, 8, 142, 52)];
        [notificationBg setFrame:CGRectMake(10, 123, 300, 138)];
        [notificationBg setImage:[UIImage imageNamed:@"notification_bg2_p.png"]];
        [notificationTitle setFrame:CGRectMake(95, 135, 130, 17)];
        [notificationMessage setFrame:CGRectMake(25, 160, 271, 18)];
        [okLabel setFrame:CGRectMake(120, 204, 81, 28)];
        [okButton setFrame:CGRectMake(93, 194, 134, 47)];
    }
}

// The delegate for textFieldShouldReturn
// Params:
//      theTextField: The text field.
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

// The delegate for textFieldShouldBeginEditing
// Params:
//      textField: The text field.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    currentTextField = textField;
    return YES;
}

// The delegate for textFieldShouldEndEditing
// Params:
//      textField: The text field.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [commentsArray replaceObjectAtIndex:textField.tag-1 withObject:textField.text];
    return YES;
}

// Called when the keyboard will show.
// Params:
//      notif: The notification
- (void) keyboardWillShow:(NSNotification *)notif {
    if (currentTextField == nil) {
        return;
    }
    // Scroll the view to keep the text field shown
    int keyboardHeight = [BCMSHelper getKeyboardHeight:notif orientation:self.interfaceOrientation];
    int moveDistance = [BCMSHelper scrollViewUp:currentTextField uiView:self.view keyboardHeight:keyboardHeight offset:scrollView.contentOffset.y];
    [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + keyboardHeight - moveDistance)];
}

// Called when the keyboard will hide.
// Params:
//      notif: The notification
- (void) keyboardWillHide:(NSNotification *)notif {
    [self setupScrollView];
    [BCMSHelper scrollViewDown:self.view];
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
    [cell.optionsLabel setTextAlignment:UITextAlignmentRight];
    cell.accessoryIcon.hidden = YES;
    NSNumber *elementInd = [NSNumber numberWithInt:section*100+row];
    // Highlight the missing elements that your required
    if ([missingElements containsObject:elementInd]) {
        [cell.cellTitle setTextColor:[UIColor redColor]];
    }
    else {
        [cell.cellTitle setTextColor:[UIColor blackColor]];
    }
    
    // Clean up the cell first
    NSArray *subViews = [cell subviews];
    for (int i = 0; i < [subViews count]; i++) {
        UIView *subView = [subViews objectAtIndex:i];
        if (subView.tag != 0) {
            [subView removeFromSuperview];
        }
    }
    int type = [[cellInfo objectForKey:@"type"] intValue];
    id value = [incidentInfo objectForKey:[cellInfo objectForKey:@"name"]];
    if (type == 0) {
        cell.optionsLabel.text = value;
        cell.accessoryIcon.hidden = NO;
        if(UIInterfaceOrientationIsLandscape(myOrientation)) {
            [cell.optionsLabel setFrame:CGRectMake(278, 0, 150, 43)];
        }
        else {
            [cell.optionsLabel setFrame:CGRectMake(150, 0, 120, 43)];
        }
    }
    else if (type == 4) {
        // Comments
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 11, 200, 20)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.tag = row + 1;
        textField.delegate = self;
        textField.placeholder = @"Type comment";
        textField.font = [UIFont systemFontOfSize:13];
        [cell addSubview:textField];
        if ([commentsArray count] <= row) {
            [commentsArray addObject:@""];
        }
        else {
            textField.text = [commentsArray objectAtIndex:row];
        }
        cell.optionsLabel.text = @"";
        cell.cellTitle.text = @"";
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
            selectionButton.tag = -1;
        }
        else {
            [selectionButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
            selectionButton.tag = 1;
        }
        [selectionButton addTarget:self action:@selector(outageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:selectionButton];
        
        UILabel *selectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 8, 250, 28)];
        selectionLabel.tag = -1;
        selectionLabel.backgroundColor = [UIColor clearColor];
        selectionLabel.text = [cellInfo objectForKey:@"title"];
        selectionLabel.font = [UIFont systemFontOfSize:14];
        [cell addSubview:selectionLabel];
    }
    else if (type == 7) {
        // Add More
        cell.cellTitle.text = @"";
        cell.optionsLabel.text = [cellInfo objectForKey:@"title"];
        [cell.optionsLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.optionsLabel setFrame:CGRectMake(10, 11, 80, 20)];
        [cell.optionsLabel setTextAlignment:UITextAlignmentLeft];
    }
    else if (type == 8) {
        // No accessory arrow
        cell.optionsLabel.text = value;
    }
    [cell.cellTitle.text capitalizedString];
    
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
	return kTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
	NSDictionary *cellInfo = [[[tableList objectAtIndex:section] objectForKey:@"items"] objectAtIndex:row];
    int type = [[cellInfo objectForKey:@"type"] intValue];
    if (type == 7) {
        // Add new comment
        NSMutableArray *comments = [[tableList objectAtIndex:section] objectForKey:@"items"];
        NSMutableDictionary *newComment = [[NSMutableDictionary alloc] init];
        [newComment setObject:@"comments" forKey:@"name"];
        [newComment setObject:@"" forKey:@"title"];
        [newComment setObject:[NSNumber numberWithInt:4] forKey:@"type"];
        [newComment setObject:[NSNumber numberWithBool:NO] forKey:@"required"];
        [comments insertObject:newComment atIndex:[comments count] - 1];
        [self doLayout:myOrientation];
    }
}
@end
