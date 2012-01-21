//
//  BCMUserSearchFilter.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMFilterRule.h"

@class BCMUserGroup;

/**
 * Describes user search filter.
 * @author proxi
 * @version 1.0
 */
@interface BCMUserSearchFilter : NSObject

@property (retain) NSNumber* userId;
@property (retain) NSString* employeeName;
@property (retain) BCMUserGroup* userGroup;
@property (assign) BCMFilterRule rule;

@end
