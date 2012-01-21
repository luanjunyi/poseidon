//
//  BCMSIncidentOptionsController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kOptionsTableCellheight 44
#define kListTypeStatus 0
#define kListTypeLocations 1
#define kListTypeSort 2
#define kBlueColor [UIColor colorWithRed:0.314 green:0.482 blue:0.639 alpha:1.0]

/*!
 @class BCMSIncidentOptionsController
 @discussion This class controls the Incident Options view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSIncidentOptionsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    // The options list
    NSMutableArray *optionsList;
    
    // List type
    int listType;
    
    // The table view
    UITableView *optionsTableView;
    
    // The title label
    UILabel *titleLabel;
    
    // The grouped list
    NSMutableDictionary *groupedCountryList;
}

// List type
@property (nonatomic, assign) int listType;

// The table view
@property (nonatomic, retain) UITableView *optionsTableView;

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
