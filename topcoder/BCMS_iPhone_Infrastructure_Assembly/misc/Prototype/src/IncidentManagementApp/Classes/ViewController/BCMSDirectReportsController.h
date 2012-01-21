//
//  BCMSDirectReportsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kDirectReportsTableCellheight 53
#define kMaxSelection 10
#define kMaxRows 100

/*!
 @class BCMSDirectReportsController
 @discussion This class controls the Direct Reports view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSDirectReportsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table view
    UITableView *theTableView;
    
    // The table list
    NSArray *tableList;
    
    // Selection array
    BOOL selectionArray[kMaxSelection];
    
    // The orientation
    UIInterfaceOrientation myOrientation;
}

// The table view
@property (nonatomic,retain) IBOutlet UITableView *theTableView;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the item in the cell
// Params:
//      sender: The sender of the action
- (IBAction)itemClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
