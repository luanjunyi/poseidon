//
//  BCMIncidentFilter.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMFilterRule.h"

@class BCMIncidentStatus;

/**
 * Describes incident filter.
 * @author proxi
 * @version 1.0
 */
@interface BCMIncidentFilter : NSObject

@property (retain) NSNumber* incidentNumber;
@property (retain) NSString* incident;
@property (retain) NSDate* reportedDate;
@property (retain) NSString* ism;
@property (retain) NSString* location;
@property (retain) BCMIncidentStatus* status;
@property (assign) BCMFilterRule rule;

@end
