//
//  CommonTest.m
//  BCMSServicesTest
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "CommonTest.h"

#import "BCMSEntities.h"

@implementation CommonTest

/**
 * Tests that <code>fromJson</code> clears all its current field values.
 */
- (void)testClearValues {
    BCMHelpDocument* entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.name = @"name";
    entity.downloadLink = @"link";
    entity.searchText = @"searchText";
    entity.documentShortDescription = @"documentShortDescription";
    
    [entity fromJSON:[NSDictionary dictionary]];
    
    STAssertNil(entity.id, @"Field not cleared");
    STAssertNil(entity.name, @"Field not cleared");
    STAssertNil(entity.downloadLink, @"Field not cleared");
    STAssertNil(entity.searchText, @"Field not cleared");
    STAssertNil(entity.documentShortDescription, @"Field not cleared");
}

- (void)testTypeMismatch {
    BCMHelpDocument* entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                                              inManagedObjectContext:managedObjectContext];
    
    STAssertThrowsSpecific(entity.id = (id)@"idstring", NSException, NSInvalidArgumentException, @"Property type is not enforced");
    STAssertThrowsSpecific(entity.name = (id)[NSNumber numberWithInteger:42], NSException, NSInvalidArgumentException, @"Property type is not enforced");
}

@end
