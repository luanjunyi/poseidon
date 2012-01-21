//
//  BCMLookupServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMLookupServiceTest.h"

@implementation BCMLookupServiceTest

/**
 * Tests that <code>BCMLookupService.getIncidentStatuses</code> returns valid data.
 */
- (void)testGetIncidentStatuses {
    NSError* error = nil;
    // test with no data
    NSSet* result = [lookupService getIncidentStatuses:[self authToken] error:&error];
    STAssertTrue([result count] == 0, @"No objects should be returned");
    
    // test with data
    [self insertEntityFromFixture:@"BCMIncidentStatus"];
    
    result = [lookupService getIncidentStatuses:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No objects returned");
    STAssertTrue([[result anyObject] isKindOfClass:[BCMIncidentStatus class]], @"Invalid object returned");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMLookupService.getContactRoles</code> returns valid data.
 */
- (void)testGetContactRoles {
    NSError* error = nil;
    // test with no data
    NSSet* result = [lookupService getContactRoles:[self authToken] error:&error];
    STAssertTrue([result count] == 0, @"No objects should be returned");
    
    // test with data
    [self insertEntityFromFixture:@"BCMContactRole"];
    
    result = [lookupService getContactRoles:[self authToken] error:&error];
    STAssertTrue([lookupService refreshData:[self authToken] error:&error], @"Refresh data failed, error (%@)", error);
    STAssertTrue([result count] > 0, @"No objects returned");
    STAssertTrue([[result anyObject] isKindOfClass:[BCMContactRole class]], @"Invalid object returned");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMLookupService.getIncidentTypes</code> returns valid data.
 */
- (void)testGetIncidentTypes {
    NSError* error = nil;
    // test with no data
    NSSet* result = [lookupService getIncidentTypes:[self authToken] error:&error];
    STAssertTrue([result count] == 0, @"No objects should be returned");
    
    // test with data
    [self insertEntityFromFixture:@"BCMIncidentType"];
    
    result = [lookupService getIncidentTypes:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No objects returned");
    STAssertTrue([[result anyObject] isKindOfClass:[BCMIncidentType class]], @"Invalid object returned");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMLookupService.getIncidentAdditionalInfos</code> returns valid data.
 */
- (void)testGetIncidentAdditionalInfos {
    NSError* error = nil;
    // test with no data
    NSSet* result = [lookupService getIncidentAdditionalInfos:[self authToken] error:&error];
    STAssertTrue([result count] == 0, @"No objects should be returned");
    
    // test with data
    [self insertEntityFromFixture:@"BCMAdditionalInfo"];
    
    result = [lookupService getIncidentAdditionalInfos:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No objects returned");
    STAssertTrue([[result anyObject] isKindOfClass:[BCMAdditionalInfo class]], @"Invalid object returned");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests that <code>BCMLookupService.getUserGroups</code> returns valid data.
 */
- (void)testGetUserGroups {
    NSError* error = nil;
    NSSet* result = [lookupService getUserGroups:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No objects returned");
    STAssertTrue([[result anyObject] isKindOfClass:[BCMUserGroup class]], @"Invalid object returned");
    STAssertNil(error, @"Error occured (%@)", error);
}

/**
 * Tests refresh data.
 */
- (void)testRefreshData {
    NSError* error = nil;
    STAssertTrue([lookupService refreshData:[self authToken] error:&error], @"Refresh data failed, error (%@)", error);
    
    // check results
    NSSet* result = [lookupService getIncidentAdditionalInfos:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No IncidentAdditionalInfos refreshed");
    
    result = [lookupService getIncidentTypes:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No IncidentTypes refreshed");
    
    result = [lookupService getUserGroups:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No UserGroups refreshed");
    
    result = [lookupService getContactRoles:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No ContactRoles refreshed");
    
    result = [lookupService getIncidentStatuses:[self authToken] error:&error];
    STAssertTrue([result count] > 0, @"No IncidentStatuses refreshed");
}


@end
