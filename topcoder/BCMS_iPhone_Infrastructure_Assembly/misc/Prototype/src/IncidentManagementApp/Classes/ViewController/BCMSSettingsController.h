//
//  BCMSSettingsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSettingsTableCellheight 46

/*!
 @class BCMSSettingsController
 @discussion This class controls the Settings view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
    
    // The title label
    UILabel *titleLabel;
    
    // The menu label
    UILabel *menuLabel;
    
    // The settings type
    int settingType;
}

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// The menu label
@property (nonatomic, retain) IBOutlet UILabel *menuLabel;

// The settings type
@property (nonatomic, assign) int settingType;

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
