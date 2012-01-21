//
//  BCMSChecklistController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSChecklistController
 @discussion This class controls the Checklist view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSChecklistController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

    // The checklist
    NSArray *checkList;
    
    // The orientation
    UIInterfaceOrientation myOrientation;
    
    // The table view
    UITableView *theTableView;
}

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// Called when clicked the checkbox
// Params:
//      sender: The sender of the action
- (IBAction)checkboxClicked:(id)sender;

// Called when clicked the close button
// Params:
//      sender: The sender of the action
- (IBAction)closeClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
