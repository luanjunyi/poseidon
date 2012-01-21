//
//  BCMSConveneRoomsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kConveneRoomsTableCellheight 46

/*!
 @class BCMSConveneRoomsController
 @discussion This class controls the Convene Rooms view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSConveneRoomsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
    
    // The delete button
    UIButton *deleteButton;
    
    // The table view
    UITableView *roomsTableView;
    
    // The notice view
    UIView *noticeView;
    
    // The notification background view;
    UIView *notificationBgView;
    
    // The notification background image
    UIImageView *notificationBg;
    
    // Whether the delete buttons should be shown
    BOOL showDelete;
}

// The delete button
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *roomsTableView;

// The notice view
@property (nonatomic, retain) IBOutlet UIView *noticeView;

// The notification background view;
@property (nonatomic, retain) IBOutlet UIView *notificationBgView;

// The notification background image
@property (nonatomic, retain) IBOutlet UIImageView *notificationBg;

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender;

// Called when clicked the YES button
// Params:
//      sender: The sender of the action
- (IBAction)yesClicked:(id)sender;

// Called when clicked the cancel button
// Params:
//      sender: The sender of the action
- (IBAction)cancelClicked:(id)sender;

// Called when clicked the delete button
// Params:
//      sender: The sender of the action
- (IBAction)deleteClicked:(id)sender;

// Called when clicked the add button
// Params:
//      sender: The sender of the action
- (IBAction)addClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
