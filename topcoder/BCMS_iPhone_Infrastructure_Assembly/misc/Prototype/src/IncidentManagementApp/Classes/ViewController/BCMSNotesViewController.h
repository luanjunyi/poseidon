//
//  BCMSNotesViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kNotesTableCellheight 70
#define kNotesTableCellheightP 120

/*!
 @class BCMSNotesViewController
 @discussion This class controls the notes view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSNotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The notes list
    NSMutableArray *notesList;
    
    // The incident id.
    int incidentId;
    
    // Whether in edit mode
    BOOL isEditing;
    
    // Edit button label
    UILabel *editButtonLabel;

    // Notes table view
    UITableView *notesTableView;
    
    // The title label
    UILabel *titleLabel;

    // The orientation
    UIInterfaceOrientation myOrientation;
}

// The incident id.
@property (nonatomic, assign) int incidentId;

// Edit button label
@property (nonatomic, retain) IBOutlet UILabel *editButtonLabel;

// Edit button label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// Notes table view
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;

// Called when clicked the add note
// Params:
//      sender: The sender of the action
- (IBAction)addNoteClicked:(id)sender;

// Called when clicked the edit note
// Params:
//      sender: The sender of the action
- (IBAction)editNoteClicked:(id)sender;

// Called when clicked the close button
// Params:
//      sender: The sender of the action
- (IBAction)closeClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
