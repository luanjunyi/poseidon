//
//  BCMSNotesViewController.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSNotesViewController.h"
#import "BCMSHelper.h"
#import "BCMSNotesTableCell.h"
#import "BCMSAddNoteViewController.h"
#import "BCMSNoteDetailsController.h"

@implementation BCMSNotesViewController
@synthesize incidentId;
@synthesize editButtonLabel;
@synthesize notesTableView;
@synthesize titleLabel;

// Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isEditing = NO;
    }
    return self;
}

#pragma mark - View lifecycle

// Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    notesList = [[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId] objectForKey:@"notes"];
    titleLabel.text = [NSString stringWithFormat:@"Note %@",[[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId] objectForKey:@"number"]];
}

// Unload
- (void)viewDidUnload
{
    self.editButtonLabel = nil;
    self.titleLabel = nil;
    self.notesTableView = nil;

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

// Called when clicked the add note
// Params:
//      sender: The sender of the action
- (IBAction)addNoteClicked:(id)sender {
    BCMSAddNoteViewController *addNoteViewController = [[BCMSAddNoteViewController alloc] initWithNibName:nil bundle:nil];
    addNoteViewController.incidentId = incidentId;
    [BCMSHelper postNotification:PushViewNotification param:addNoteViewController];
}

// Called when clicked the edit note
// Params:
//      sender: The sender of the action
- (IBAction)editNoteClicked:(id)sender {
    isEditing = !isEditing;
    if (isEditing) {
        editButtonLabel.text = @"Done";
    }
    else {
        editButtonLabel.text = @"Edit";
    }
    [notesTableView reloadData];
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
	return [notesList count];
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"NotesListCellIdentifier";
    
    // Prepare cell information
	NSUInteger row = [indexPath row];
	NSDictionary *cellInfo = [notesList objectAtIndex:row];
    
	// Use customized cell
	BCMSNotesTableCell *cell = (BCMSNotesTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCMSNotesTableCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    NSDate *noteDate = [[[[[[BCMSHelper getDataSource] objectForKey:@"Data"] objectForKey:@"incidents"] objectForKey:@"items"] objectAtIndex:incidentId] objectForKey:@"date"];
    cell.noteDateLabel.text = [BCMSHelper convertDateToString:noteDate];
    cell.noteDetailLabel.text = [cellInfo objectForKey:@"details"];
    
    [cell.deleteButton setHidden:!isEditing];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIInterfaceOrientationIsPortrait(myOrientation)) {
        return kNotesTableCellheightP;
    }
	return kNotesTableCellheight;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deal with the selection
	int row = [indexPath row];
    BCMSNoteDetailsController *noteDetailsController = [[BCMSNoteDetailsController alloc] initWithNibName:nil bundle:nil];
    noteDetailsController.incidentId = incidentId;
    noteDetailsController.noteId = row;
    [BCMSHelper postNotification:PushViewNotification param:noteDetailsController];
    [tableView reloadData];
}

@end
