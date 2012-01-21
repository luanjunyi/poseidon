//
//  BCMRefreshLog.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BCMRefreshLog : NSManagedObject

@property (nonatomic, retain) NSString * bcmEntityName;
@property (nonatomic, retain) NSDate * lastRefreshTime;

@end
