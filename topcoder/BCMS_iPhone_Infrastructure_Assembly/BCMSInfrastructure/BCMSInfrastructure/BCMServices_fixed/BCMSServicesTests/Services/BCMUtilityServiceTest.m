//
//  BCMUtilityServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUtilityServiceTest.h"

#import "BCMUtilityService.h"

@implementation BCMUtilityServiceTest

/**
 * Tests set last refresh time for entity.
 */
-(void)testSetLastRefreshTimeFor
{
    NSString *entityName = @"TheTestSetEntity";
    
    // Save log record for entity
    //
    NSError* error = nil;
    STAssertTrue([utilityService setLastRefreshTimeFor:entityName error:&error], @"Operation failed");
    
    // check if log entity was saved
    //
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"BCMRefreshLog"
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(bcmEntityName LIKE %@)", entityName];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    STAssertTrue(array.count == 1, @"Refresh log record not found for entity");
    STAssertEqualObjects([[array lastObject] bcmEntityName], entityName, @"Found wrong entity log");
}

/**
 * Tests get last refresh time for entity.
 */
-(void)testGetLastRefreshTimeFor
{
    NSString *entityName = @"TheTestGetEntity";
    NSError* error = nil;
    NSDate * lastTime = [utilityService getLastRefreshTimeFor:entityName error:&error];
    STAssertNil(lastTime, @"Returned the last refresh time for non existing entity");
    
    // create new log record
    BCMRefreshLog *entity = (BCMRefreshLog *)[NSEntityDescription insertNewObjectForEntityForName:@"BCMRefreshLog"
                                                                           inManagedObjectContext:managedObjectContext];
    entity.bcmEntityName = entityName;
    NSDate* testDate = [NSDate date];
    entity.lastRefreshTime = testDate;
    [managedObjectContext insertObject:entity];
    
    // check if we can get last refresh time
    error = nil;
    lastTime = [utilityService getLastRefreshTimeFor:entityName error:&error];
    STAssertNotNil(lastTime, @"Failed to get last refresh time, error (%@)", error);
    STAssertTrue([lastTime isEqualToDate:testDate], @"Incorrect last refresh time retrieved!");
}

/**
 * Tests clear local data.
 */
-(void)testClearLocalData
{
    // save test data to the local store
    BCMRefreshLog *entity = (BCMRefreshLog *)[NSEntityDescription insertNewObjectForEntityForName:@"BCMRefreshLog"
                                                                           inManagedObjectContext:managedObjectContext];
    entity.bcmEntityName = @"Test entity";
    NSDate* testDate = [NSDate date];
    entity.lastRefreshTime = testDate;
    
    // test clear data
    NSError* error = nil;
    STAssertTrue([utilityService clearLocalData:&error], @"Failed to clear local data, error (%@)", error);
    
    NSEntityDescription* entDescr = [NSEntityDescription entityForName:@"BCMRefreshLog"
                                                inManagedObjectContext:managedObjectContext];
    NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
    [fetch setEntity:entDescr];
    error = nil;
    NSArray * result = [managedObjectContext executeFetchRequest:fetch error:&error];
    STAssertNil(error, @"Failed to test clear local data due to unepected error");
    STAssertTrue(result.count == 0, @"The objects still remain in local data context after clear!");
    
}

@end
