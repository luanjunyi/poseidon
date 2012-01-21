//
//  BCMPagedResult.m
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMPagedResult.h"

@implementation BCMPagedResult

@synthesize startCount;
@synthesize pageSize;
@synthesize totalCount;
@synthesize values;

- (void)dealloc {
    [values release];
    
    [super dealloc];
}

@end
