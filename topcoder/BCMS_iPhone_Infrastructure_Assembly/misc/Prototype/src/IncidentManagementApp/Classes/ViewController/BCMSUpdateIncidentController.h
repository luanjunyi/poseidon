//
//  BCMSUpdateIncidentController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTableCellheight 44

/*!
 @class BCMSUpdateIncidentController
 @discussion This class controls the Update Incident View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSUpdateIncidentController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    // The table list
    NSArray *tableList;
    
    // The scroll view
    UIScrollView *scrollView;
    
    // The valication view
    UIView *validationView;

    // The table content view
    UIView *tableContentView;
    
    // The buttons view
    UIView *buttonsView;

    // Unfilled elements that are required
    NSMutableSet *missingElements;
    
    // The incident information
    NSMutableDictionary *incidentInfo;
    
    // The table view
    UITableView *theTableView;
    
    // The current text field
    UITextField *currentTextField;
    
    // The title label
    UILabel *titleLabel;
    
    // Cancel button
    UIButton *cancelButton;
    
    // Done button
    UIButton *doneButton;

    // The notification background
    UIImageView *notificationBg;
    
    // The notification title
    UILabel *notificationTitle;
    
    // The notification message
    UILabel *notificationMessage;
    
    // The ok button
    UIButton *okButton;
    
    // The ok label
    UILabel *okLabel;
    
    // The group header label
    UILabel *groupHeaderLabel;
    
    // The group header view
    UIView *groupHeaderView;

    // The incident id
    int incidentId;
    
    // The orientation
    UIInterfaceOrientation myOrientation;
    
    // The comments array
    NSMutableArray *commentsArray;
}

// The scroll view
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// The valication view
@property (nonatomic, retain) IBOutlet UIView *validationView;

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// The table content view
@property (nonatomic, retain) IBOutlet UIView *tableContentView;

// The buttons view
@property (nonatomic, retain) IBOutlet UIView *buttonsView;

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// Cancel button
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

// Done button
@property (nonatomic, retain) IBOutlet UIButton *doneButton;

// The group header label
@property (nonatomic, retain) IBOutlet UILabel *groupHeaderLabel;

// The group header view
@property (nonatomic, retain) IBOutlet UIView *groupHeaderView;

// The notification background
@property (nonatomic, retain) IBOutlet UIImageView *notificationBg;

// The notification title
@property (nonatomic, retain) IBOutlet UILabel *notificationTitle;

// The notification message
@property (nonatomic, retain) IBOutlet UILabel *notificationMessage;

// The ok button
@property (nonatomic, retain) IBOutlet UIButton *okButton;

// The ok label
@property (nonatomic, retain) IBOutlet UILabel *okLabel;

// The incident id
@property (nonatomic, assign) int incidentId;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Called when clicked the done button
// Params:
//      sender: The sender of the action
- (IBAction)doneClicked:(id)sender;

// Called when clicked the OK button
// Params:
//      sender: The sender of the action
- (IBAction)okClicked:(id)sender;

// Called when clicked the outage button
// Params:
//      sender: The sender of the action
- (IBAction)outageButtonClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
