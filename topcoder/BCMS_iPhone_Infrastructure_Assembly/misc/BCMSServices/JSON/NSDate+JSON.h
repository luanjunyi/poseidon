//
//  NSDate+JSON.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

/**
 * <code>NSDate</code> category with methods to serialize <code>NSDate</code>s
 * to and from JSON string representation.
 * @author proxi
 * @version 1.0
 */
@interface NSDate(JSON)

/**
 * Returns <code>NSDate</code> from JSON string representation.
 * @param string String to parse.
 * @return <code>NSDate</code> from given string.
 */
+ (NSDate*)dateFromJSON:(NSString*)string;

/**
 * Converts given <code>NSDate</code> to JSON string representation.
 * @param date Date to convert.
 * @return JSON string value for given date.
 */
+ (NSString*)jsonStringFromDate:(NSDate*)date;

@end
