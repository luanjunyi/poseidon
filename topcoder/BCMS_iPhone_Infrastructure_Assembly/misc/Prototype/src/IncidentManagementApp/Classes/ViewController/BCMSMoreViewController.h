//
//  BCMSMoreViewController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMoreTableCellheight 46

/*!
 @class BCMSMoreViewController
 @discussion This class controls the More View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSMoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
}

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
