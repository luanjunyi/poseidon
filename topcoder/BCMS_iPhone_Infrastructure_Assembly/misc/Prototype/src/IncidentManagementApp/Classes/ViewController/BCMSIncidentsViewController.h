//
//  BCMSIncidentsViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kIncidentsTableCellheight 78
#define kIncidentsTableCellheightP 100
#define IncidentStatusNewString @"NEW"
#define IncidentStatusActiveString @"ACTIVE"
#define IncidentStatusClosedString @"CLOSED"
#define IncidentStatusPendingString @"PENDING"

/*!
 @class BCMSIncidentsViewController
 @discussion This class controls the Incidents View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSIncidentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    // The incidents list
    NSArray *incidentsList;
    
    // The current orientation
    UIInterfaceOrientation myOrientation;
    
    // The table view
    UITableView *theTableView;
}

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender;

// Called when clicked the filter button
// Params:
//      sender: The sender of the action
- (IBAction)filterClicked:(id)sender;

// Called when clicked the add new incident button
// Params:
//      sender: The sender of the action
- (IBAction)addNewIncidentClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
