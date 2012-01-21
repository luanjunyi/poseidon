//
//  BCMContactRole.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMContact;

@interface BCMContactRole : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *inverseContacts;
@end

@interface BCMContactRole (CoreDataGeneratedAccessors)

- (void)addInverseContactsObject:(BCMContact *)value;
- (void)removeInverseContactsObject:(BCMContact *)value;
- (void)addInverseContacts:(NSSet *)values;
- (void)removeInverseContacts:(NSSet *)values;
@end
