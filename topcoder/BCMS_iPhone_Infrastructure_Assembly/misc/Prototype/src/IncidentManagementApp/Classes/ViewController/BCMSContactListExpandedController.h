//
//  BCMSContactListExpandedController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kContactListExpandedTableCellheight 44

/*!
 @class BCMSContactListExpandedController
 @discussion This class controls the Contact List expanded View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSContactListExpandedController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table information
    NSDictionary *tableInfo;

    // The table list
    NSArray *tableList;

    // The title label
    UILabel *titleLabel;

    // The acronym label
    UILabel *acronymLabel;

    // The table view
    UITableView *theTableView;
    
    // The list type
    int listType;
    
    // The orientation
    UIInterfaceOrientation myOrientation;
}

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// The acronym label
@property (nonatomic, retain) IBOutlet UILabel *acronymLabel;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// The list type
@property (nonatomic, assign) int listType;

// The table information
@property (nonatomic, retain) NSDictionary *tableInfo;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
