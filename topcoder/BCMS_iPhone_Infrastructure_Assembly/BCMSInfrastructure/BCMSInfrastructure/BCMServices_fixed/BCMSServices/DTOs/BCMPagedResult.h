//
//  BCMPagedResult.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

/**
 * Container for paged result from the service.
 * @author proxi
 * @version 1.0
 */
@interface BCMPagedResult : NSObject

@property (assign) NSUInteger startCount;
@property (assign) NSUInteger pageSize;
@property (assign) NSUInteger totalCount;
@property (retain) NSArray* values;

@end
