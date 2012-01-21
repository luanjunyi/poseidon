//
//  BCMSIncidentFilterSortController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kOptionsTableCellheight 44

/*!
 @class BCMSIncidentFilterSortController
 @discussion This class controls the Incident Filter and Sortview.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSIncidentFilterSortController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    // The options list
    NSMutableArray *optionsList;
    
    // The table view
    UITableView *optionsListView;
    
    // The orientation
    UIInterfaceOrientation myOrientation;
}

// The table view
@property (nonatomic, retain) IBOutlet UITableView *optionsListView;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
