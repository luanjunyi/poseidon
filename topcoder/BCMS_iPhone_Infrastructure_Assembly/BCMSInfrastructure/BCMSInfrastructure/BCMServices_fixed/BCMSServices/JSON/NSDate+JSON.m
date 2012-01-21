//
//  NSDate+JSON.m
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "NSDate+JSON.h"

@implementation NSDate(JSON)

/**
 * Returns <code>NSDate</code> from JSON string representation.
 * @param string String to parse.
 * @return <code>NSDate</code> from given string.
 */
+ (NSDate*)dateFromJSON:(NSString*)string {
    NSString* pattern = @"\\/Date\\((\\d+)((?:[\\+\\-]\\d+)?)\\)\\/"; // /Date(milliseconds)/ or /Date(milliseconds-zzzz)/
    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult* match = [regexp firstMatchInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length])];
    if (!match) {
        return nil;
    }
    NSRange millisecondsRange = [match rangeAtIndex:1];
    if (millisecondsRange.location == NSNotFound) {
        return nil;
    }
    NSString* millisecondsString = [string substringWithRange:millisecondsRange];
    
    NSTimeInterval seconds = ((NSTimeInterval)[millisecondsString doubleValue]) / 1000.0;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    return date;
}

/**
 * Converts given <code>NSDate</code> to JSON string representation.
 * @param date Date to convert.
 * @return JSON string value for given date.
 */
+ (NSString*)jsonStringFromDate:(NSDate*)date {
    NSTimeInterval milliseconds = [date timeIntervalSince1970] * 1000.0;
    return [NSString stringWithFormat:@"/Date(%1.0lf)/", milliseconds];
}

@end
