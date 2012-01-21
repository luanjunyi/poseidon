//
//  BCMSContactDetailsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kContactDetailsTableCellheight 53

/*!
 @class BCMSContactDetailsController
 @discussion This class controls the Contact Details View.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSContactDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The table list
    NSArray *tableList;
    
    // The table view
    UITableView *theTableView;
    
    // The scroll view
    UIScrollView *scrollView;
}

// The table view
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

// The scroll view
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// The table list
@property (nonatomic, retain) NSArray *tableList;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
