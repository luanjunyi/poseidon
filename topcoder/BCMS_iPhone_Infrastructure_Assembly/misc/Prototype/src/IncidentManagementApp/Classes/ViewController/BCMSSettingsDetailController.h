//
//  BCMSSettingsDetailController.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class BCMSSettingsDetailController
 @discussion This class controls the Settings Detail view.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.
 
 @author subchap
 @version 1.1
 */
@interface BCMSSettingsDetailController : UIViewController <UITextViewDelegate> {
    // The name label
    UILabel *nameLabel;

    // The title label
    UILabel *titleLabel;

    // The detail text view
    UITextView *detailTextView;
    
    // The content view
    UIView *contentView;
    
    // The scroll view
    UIScrollView *scrollView;
    
    // The setting type.
    int settingType;
    
    // The detail id
    int detailId;
}

// The name label
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

// The title label
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// The detail text view
@property (nonatomic, retain) IBOutlet UITextView *detailTextView;

// The content view
@property (nonatomic, retain) IBOutlet UIView *contentView;

// The scroll view
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// The setting type.
@property (nonatomic, assign) int settingType;

// The detail id
@property (nonatomic, assign) int detailId;

// Called when clicked the back button
// Params:
//      sender: The sender of the action
- (IBAction)backClicked:(id)sender;

// Adjust the view layout according to the orientation
// Params:
//      orientation: The current orientation.
- (void)doLayout:(UIInterfaceOrientation)orientation;

@end
