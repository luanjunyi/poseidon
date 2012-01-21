//
//  BCMHelpDocument.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BCMHelpDocument : NSManagedObject

@property (nonatomic, retain) NSString * documentShortDescription;
@property (nonatomic, retain) NSString * downloadLink;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * searchText;

@end
