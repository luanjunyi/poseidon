//
//  BCMSIncidentDetailsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTableCellheight 44

/*!
 @class BCMSIncidentDetailsController
 @discussion This class controls the Incident Details view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSIncidentDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The menu button
    UIButton *menuButton;
    
    // The go to top button
    UIButton *gotoTopButton;
    
    // The header label
    UILabel *headerLabel;
    
    // The functions view
    UIView *functionsView;
    
    // The table list
    NSArray *tableList;
    
    // The incident information
    NSDictionary *incidentInfo;
    
    // The incident id.
    int incidentId;
    
    // The orientation
    UIInterfaceOrientation myOrientation;
    
    // The table view
    UITableView *theTableView;
    
    // The group header label
    UILabel *groupHeaderLabel;
    
    // The group header view
    UIView *groupHeaderView;
    
    // The scroll view
    UIScrollView *scrollView;
    
    // The notification background
    UIImageView *notificationBg;
    
    // The checklist button
    UIButton *checkListButton;

    // The note button
    UIButton *noteButton;

    // The attachments button
    UIButton *attachmentsButton;

    // The update button
    UIButton *updateButton;
}

// The menu button
@property (nonatomic, retain) IBOutlet UIButton *menuButton;

// The header label
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;

// The functions view
@property (nonatomic, retain) IBOutlet UIView *functionsView;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// The go to top button
@property (nonatomic, retain) IBOutlet UIButton *gotoTopButton;

// The scroll view
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// The notification background
@property (nonatomic, retain) IBOutlet UIImageView *notificationBg;

// The checklist button
@property (nonatomic, retain) IBOutlet UIButton *checkListButton;

// The note button
@property (nonatomic, retain) IBOutlet UIButton *noteButton;

// The attachments button
@property (nonatomic, retain) IBOutlet UIButton *attachmentsButton;

// The update button
@property (nonatomic, retain) IBOutlet UIButton *updateButton;

// The incident id.
@property (nonatomic, assign) int incidentId;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the menu button
// Params:
//      sender: The sender of the action
- (IBAction)menuClicked:(id)sender;

// Called when clicked the menu buttons
// Params:
//      sender: The sender of the action
- (IBAction)menuButtonsClicked:(id)sender;

// Called when clicked the goto top button
// Params:
//      sender: The sender of the action
- (IBAction)gotoTopButtonsClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
