//
//  BCMSHelper.h
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kKeyboardAnimationDuration 0.3
#define kGeneralAnimationDuration 0.3
#define PushViewNotification @"PushViewNotification"
#define PopViewNotification @"PopViewNotification"
#define kMaxTextHeight 300

/*!
 @class BCMSHelper
 @discussion This class is helper class the app.
 
 @changes from 1.0:
 Updated for "BCMS Incident Management iPhone Application Portrait Prototype Conversion Assembly". Support for portrait orientation is added.

 @author subchap
 @version 1.1
*/
@interface BCMSHelper : NSObject

// Scroll the view up when the keyboard is shown
// Params:
//      textField: The text field for input
//      parentView: The parent view
//      keyboardHeight: The height of the keyboard
//      offset: The offset for scroll
+ (int)scrollViewUp:(UITextField *)textField uiView:(UIView *)parentView keyboardHeight:(int)keyboardHeight offset:(int)offset;

// Scroll the view down when the keyboard is hidden
// Params:
//      uiView: The UIView
+ (void)scrollViewDown:(UIView *)uiView;

// Fade the view in
// Params:
//      uiView: The UIView
//      parentView: The parent view of uiView
+ (void)fadeViewIn:(UIView *)uiView parentView:(UIView *)parentView;

// Fade the view out
// Params:
//      uiView: The UIView
//      parentView: The parent view of uiView
+ (void)fadeViewOut:(UIView *)uiView parentView:(UIView *)parentView;

// Find the keyboard height
// Params:
//      notif: The notification
//      orientation: The current orientation
+ (int)getKeyboardHeight:(NSNotification *)notif orientation:(UIInterfaceOrientation)orientation;

// Get the app data source.
// Return: The data source.
+(NSDictionary *) getDataSource;

// Refresh the app data source.
// Return: The data source.
+(NSDictionary *) refreshDataSource;

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToString:(NSDate *) date;

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToStringFormat2:(NSDate *) date;

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToStringFormat3:(NSDate *) date;

// Post a notification
// Params:
//      notificationName: The notification name.
//      param: The parameter
+ (void) postNotification:(NSString *)notificationName param:(id)param;

// Adjust the details label frame
// Params:
//      detailsLabel: The details label.
//      text: The text
//      orientation: The orientation
+ (void)setupDetailsLabel:(UILabel *)detailsLabel text:(NSString *)text orientation:(UIInterfaceOrientation)orientation;

// Calculate the details label frame
// Params:
//      text: The text
//      orientation: The orientation
+ (CGRect)calculateDetailsLabelFrame:(NSString *)text orientation:(UIInterfaceOrientation)orientation;

// Setup round view
// Params:
//      theView: The view to be setup
+ (void)setupRoundView:(UIView *)theView;

@end
