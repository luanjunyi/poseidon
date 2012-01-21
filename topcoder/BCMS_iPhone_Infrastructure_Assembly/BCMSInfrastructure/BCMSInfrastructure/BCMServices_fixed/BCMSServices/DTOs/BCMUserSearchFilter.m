//
//  BCMUserSearchFilter.m
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUserSearchFilter.h"

@implementation BCMUserSearchFilter

@synthesize userId;
@synthesize employeeName;
@synthesize userGroup;
@synthesize rule;

- (void)dealloc {
    [userId release];
    [employeeName release];
    [userGroup release];
    
    [super dealloc];
}

@end
