//
//  ServiceTest.m
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "ServiceTest.h"

#import "BCMSEntities.h"

@implementation ServiceTest

/**
 * Tests parsing of response from CacheUpdatesService#GetAreaOfficesModifiedSince demo case.
 */
- (void)testCacheUpdatesService_GetAreaOfficesModifiedSinceResponse {
    NSDictionary* fixture = [self readFixture:@"CacheUpdatesService_GetAreaOfficesModifiedSince.json"];
    
    BCMPagedResult* pagedResult = [BCMPagedResult pagedResultForEntityName:@"BCMAreaOffice"
                                                    inManagedObjectContext:managedObjectContext
                                                                  fromJSON:fixture];
    
    STAssertEquals([pagedResult.values count], pagedResult.pageSize, @"Invalid number of values");
    STAssertNotNil(pagedResult, @"Could not parse service response");
}

/**
 * Tests parsing of response from CacheUpdatesService#GetIncidentsModifiedSince demo case.
 */
- (void)testCacheUpdatesService_GetIncidentsModifiedSinceResponse {
    NSDictionary* fixture = [self readFixture:@"CacheUpdatesService_GetIncidentsModifiedSince.json"];
    
    BCMPagedResult* pagedResult = [BCMPagedResult pagedResultForEntityName:@"BCMIncident"
                                                    inManagedObjectContext:managedObjectContext
                                                                  fromJSON:fixture];
    
    STAssertEquals([pagedResult.values count], pagedResult.pageSize, @"Invalid number of values");
    STAssertNotNil(pagedResult, @"Could not parse service response");
}

/**
 * Tests parsing of response from UserService#GetUsers demo case.
 */
- (void)testUserService_GetUsersResponse {
    NSDictionary* fixture = [self readFixture:@"UserService_GetUsers.json"];
    
    BCMPagedResult* pagedResult = [BCMPagedResult pagedResultForEntityName:@"BCMUser"
                                                    inManagedObjectContext:managedObjectContext
                                                                  fromJSON:fixture];
    
    STAssertEquals([pagedResult.values count], pagedResult.pageSize, @"Invalid number of values");
    STAssertNotNil(pagedResult, @"Could not parse service response");
}

@end
