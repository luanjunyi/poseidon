//
//  BCMSMenuViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTableCellheight 40
#define kTableCellheightP 50

/*!
 @class BCMSMenuViewController
 @discussion This class controls the menu view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The user information label
    UILabel *userInfoLabel;
    
    // The menu list
    NSArray *menuList;
    
    // The current orientation
    UIInterfaceOrientation myOrientation;
    
    // The table view
    UITableView *theTableView;
    
    // Welcome label
    UILabel *wecomeLabel;
}

// The user information label
@property (nonatomic, retain) IBOutlet UILabel *userInfoLabel;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// Welcome label
@property (nonatomic, retain) IBOutlet UILabel *wecomeLabel;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
