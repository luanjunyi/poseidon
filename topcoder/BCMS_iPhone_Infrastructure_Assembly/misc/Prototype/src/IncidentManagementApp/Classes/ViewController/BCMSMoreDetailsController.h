//
//  BCMSMoreDetailsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMoreDetailsTableCellheight 153

/*!
 @class BCMSMoreDetailsController
 @discussion This class controls the More Details View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSMoreDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
    
    // The title label
    UILabel *titleLabel;
    
    // The table view
    UITableView *theTableView;
    
    // The more list type
    int moreListType;
    
    // The more details index
    int moreDetailsIndex;
    
    // The orientation
    UIInterfaceOrientation myOrientation;   
}

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// The more list type
@property (nonatomic, assign) int moreListType;

// The more details index
@property (nonatomic, assign) int moreDetailsIndex;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
