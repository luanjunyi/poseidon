//
//  BCMSNewIncidentController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSNewIncidentController.h"
#import "BCMSHelper.h"
#import "BCMSOptionsTableCell.h"

@implementation BCMSNewIncidentController
@synthesize scrollView;
@synthesize validationView;
@synthesize theTableView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize notificationBg;
@synthesize notificationTitle;
@synthesize notificationMessage;
@synthesize okButton;
@synthesize okLabel;

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
    tableList = [[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"addNew"];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [scrollView setContentSize:CGSizeMake(480, 840)];
    }
    else {
        [scrollView setContentSize:CGSizeMake(320, 840)];
    }
    missingElements = [[NSMutableSet alloc] init];
    inputDict = [[NSMutableDictionary alloc] init];
    currentTextField = nil;
    
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
    self.cancelButton = nil;
    self.doneButton = nil;
    self.notificationBg = nil;
    self.notificationTitle = nil;
    self.notificationMessage = nil;
    self.okButton = nil;
    self.okLabel = nil;
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

// The delegate for textField:shouldChangeCharactersInRange:replacementString:.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [inputDict setObject:textField.text forKey:[NSNumber numberWithInt:textField.tag]];
    return YES;
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
        NSArray *items = [[tableList objectAtIndex:i] objectForKey:@"items"];
        for (int j = 0; j < [items count]; j++) {
            NSDictionary *item = [items objectAtIndex:j];
            if ([[item objectForKey:@"required"] boolValue]) {
                NSNumber *index = [NSNumber numberWithInt:i * 100 + j];
                if ([inputDict objectForKey:index] == nil || [[[inputDict objectForKey:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
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
        // In this Assembly, simply return,
        [BCMSHelper postNotification:PopViewNotification param:nil];
    }
}

// Called when clicked the OK button
// Params:
//      sender: The sender of the action
- (IBAction)okClicked:(id)sender {
    [BCMSHelper fadeViewOut:validationView parentView:self.view];
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
    [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, 840)];
    [BCMSHelper scrollViewDown:self.view];
}

// Setup the content size of the scroll view
- (void)setupScrollView {
    if (UIInterfaceOrientationIsLandscape(myOrientation)) {
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

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation {
    myOrientation = orientation;
    [theTableView reloadData];
    [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.1];
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
    
    // Fill the cell properties
    cell.cellTitle.text = [cellInfo objectForKey:@"title"];
    NSNumber *elementInd = [NSNumber numberWithInt:section*100+row];
    int type = [[cellInfo objectForKey:@"type"] intValue];
    if (type == 0) {
        cell.optionsLabel.text = nil;
        cell.accessoryIcon.hidden = YES;
        UITextField *textField = nil;
        for (int i = 0; i < [[cell subviews] count]; i++) {
            if ([[[cell subviews] objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                textField = [[cell subviews] objectAtIndex:i];
                break;
            }
        }
        
        if (textField == nil) {
            textField = [[UITextField alloc] initWithFrame:CGRectMake([[cellInfo objectForKey:@"offset"] intValue], 10, 200, cell.optionsLabel.frame.size.height)];
            [cell addSubview:textField];
        }
        
        [textField setPlaceholder:[cellInfo objectForKey:@"default"]];
        [textField setBorderStyle:UITextBorderStyleNone];
        if ([inputDict objectForKey:elementInd] != nil) {
            textField.text = [inputDict objectForKey:elementInd];
        }
        textField.delegate = self;
        textField.tag = section * 100 + row;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else {
        if(UIInterfaceOrientationIsLandscape(myOrientation)) {
            [cell.optionsLabel setFrame:CGRectMake(278, 0, 150, 43)];
        }
        else {
            [cell.optionsLabel setFrame:CGRectMake(150, 0, 120, 43)];
        }
        cell.optionsLabel.text = [cellInfo objectForKey:@"default"];
        cell.accessoryIcon.hidden = NO;
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    // Highlight the missing elements that your required
    if ([missingElements containsObject:elementInd]) {
        [cell.cellTitle setTextColor:[UIColor redColor]];
    }
    else {
        [cell.cellTitle setTextColor:[UIColor blackColor]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *tableItem = [tableList objectAtIndex:section];
    if ([[tableItem objectForKey:@"showHeader"] boolValue]) {
        return 25;
    }
	return 5;
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do nothing in this Assembly.
}

@end
