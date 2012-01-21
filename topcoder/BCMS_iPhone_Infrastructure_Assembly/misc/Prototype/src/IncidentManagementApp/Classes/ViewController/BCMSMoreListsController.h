//
//  BCMSMoreListsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMoreTableCellheight 46

/*!
 @class BCMSMoreListsController
 @discussion This class controls the More Lists View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSMoreListsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
    
    // The title label
    UILabel *titleLabel;
    
    // The table view
    UITableView *theTableView;
    
    // The more list type
    int moreListType;
}

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// The table view
@property (nonatomic, retain) UITableView *theTableView;

// The more list type
@property (nonatomic, assign) int moreListType;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
