//
//  BCMSHelper.m
//  IncidentManagementApp
//
//  Created by subchap on 11/3/11.
//  Copyright 2011 TopCoder Inc. All rights reserved.
//

#import "BCMSHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCMSHelper

// The static data source.
static NSDictionary *dataSource = nil;

// Initialization
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// Scroll the view up when the keyboard is shown
// Params:
//      textField: The text field for input
//      parentView: The parent view
//      keyboardHeight: The height of the keyboard
//      offset: The offset for scroll
+ (int)scrollViewUp:(UITextField *)textField uiView:(UIView *)parentView keyboardHeight:(int)keyboardHeight offset:(int)offset {
    // Find the position of the textfield
    int location = 0;
    UIView *thisView = textField;
    while (thisView != parentView) {
        location += thisView.frame.origin.y;
        thisView = thisView.superview;
    }
    
    // Calculate the distance to move
    int moveDistance = keyboardHeight - (thisView.frame.size.height - location - textField.frame.size.height) - offset;
    if (moveDistance <= 0) {
        return 0;
    }
    else {
        // Animate the move
        CGRect viewFrame = thisView.frame;
        viewFrame.origin.y -= moveDistance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kKeyboardAnimationDuration];
        [thisView setFrame:viewFrame];
        [UIView commitAnimations];
    }
    return moveDistance;
}

// Scroll the view down when the keyboard is hidden
// Params:
//      uiView: The UIView
+ (void)scrollViewDown:(UIView *)uiView {
    if (uiView.frame.origin.y != 0) {
        // Animate the move
        CGRect viewFrame = uiView.frame;
        viewFrame.origin.y = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kKeyboardAnimationDuration];
        [uiView setFrame:viewFrame];
        [UIView commitAnimations];
    }
}

// Fade the view in
// Params:
//      uiView: The UIView
//      parentView: The parent view of uiView
+ (void)fadeViewIn:(UIView *)uiView parentView:(UIView *)parentView {
    [uiView setAlpha:0.0];
    [uiView setHidden:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kGeneralAnimationDuration];
    [uiView setAlpha:1.0];
    [UIView commitAnimations];
}

// Fade the view out
// Params:
//      uiView: The UIView
//      parentView: The parent view of uiView
+ (void)fadeViewOut:(UIView *)uiView parentView:(UIView *)parentView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kGeneralAnimationDuration];
    [uiView setAlpha:0.0];
    [UIView commitAnimations];
}

// Find the keyboard height
// Params:
//      notif: The notification
//      orientation: The current orientation
+ (int)getKeyboardHeight:(NSNotification *)notif orientation:(UIInterfaceOrientation)orientation{
    // get the size of the keyboard
    NSDictionary* userInfo = [notif userInfo];
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGSize keyboardSize = keyboardEndFrame.size;
    
    // Move the view
    int keyboardHeight;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        keyboardHeight = keyboardSize.width;
    }
    else {
        keyboardHeight = keyboardSize.height;
    }
    return keyboardHeight;
}

// Get the app data source.
// Return: The data source.
+(NSDictionary *) getDataSource {
    if (dataSource != nil) {
        return dataSource;
    }
    // read configure data
    dataSource = [BCMSHelper refreshDataSource];
    return dataSource;
}

// Refresh the app data source.
// Return: The data source.
+(NSDictionary *) refreshDataSource {
    // read configure data
    NSString *dataSourcePath = [[NSBundle mainBundle] pathForResource:@"DataSource" ofType:@"plist"];
    
    dataSource = [[NSMutableDictionary alloc] initWithContentsOfFile:dataSourcePath];
    return dataSource;
}

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToString:(NSDate *) date {   
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation: @"EST"]];
    [dateFormat setDateFormat:@"MMM dd,yyyy / HH:mm z"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToStringFormat2:(NSDate *) date {   
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation: @"EST"]];
    [dateFormat setDateFormat:@"MMM dd,yyyy | HH:mm:ss z"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

// This method converts a date to a string with the required format.
// Params:
//      date: The given date.
// Return: The converted string.
+ (NSString*) convertDateToStringFormat3:(NSDate *) date {   
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation: @"EST"]];
    [dateFormat setDateFormat:@"MMM dd,yyyy HH:mm:ss z"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

// Post a notification
// Params:
//      notificationName: The notification name.
//      param: The parameter
+ (void) postNotification:(NSString *)notificationName param:(id)param {
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:param];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

// Adjust the details label frame
// Params:
//      detailsLabel: The details label.
//      text: The text
//      orientation: The orientation
+ (void)setupDetailsLabel:(UILabel *)detailsLabel text:(NSString *)text orientation:(UIInterfaceOrientation)orientation {
    [detailsLabel setFrame:[BCMSHelper calculateDetailsLabelFrame:text orientation:orientation]];
    detailsLabel.text = text;
    detailsLabel.font = [UIFont systemFontOfSize:14];
    [detailsLabel setNumberOfLines:0];
    detailsLabel.tag = -1;
    [detailsLabel setBackgroundColor:[UIColor clearColor]];
}

// Calculate the details label frame
// Params:
//      text: The text
//      orientation: The orientation
+ (CGRect)calculateDetailsLabelFrame:(NSString *)text orientation:(UIInterfaceOrientation)orientation {
    int maxWidth = 320;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        maxWidth = 480;
    }
    CGSize labelSize = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(maxWidth - 40, kMaxTextHeight)];
    return CGRectMake(20, 40, labelSize.width, labelSize.height);
}

// Setup round view
// Params:
//      theView: The view to be setup
+ (void)setupRoundView:(UIView *)theView {
    theView.layer.borderColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
    theView.layer.borderWidth = 1.0;
    [theView.layer setCornerRadius:10.0];
}
@end
