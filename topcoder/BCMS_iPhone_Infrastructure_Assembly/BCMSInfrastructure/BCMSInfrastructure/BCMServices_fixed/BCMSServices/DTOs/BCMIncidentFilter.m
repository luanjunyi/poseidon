//
//  BCMIncidentFilter.m
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMIncidentFilter.h"

@implementation BCMIncidentFilter

@synthesize incidentNumber;
@synthesize incident;
@synthesize reportedDate;
@synthesize ism;
@synthesize location;
@synthesize status;
@synthesize rule;

- (void)dealloc {
    [incidentNumber release];
    [incident release];
    [reportedDate release];
    [ism release];
    [location release];
    [status release];
    
    [super dealloc];
}

@end
