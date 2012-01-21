//
//  BCMUserServiceTest.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMUserServiceTest.h"

#import "NSManagedObjectContext+Utility.h"
#import "BCMUserService.h"
#import "BCMUser.h"

@implementation BCMUserServiceTest

/**
 * Set up environment for testing.
 */
- (void)setUp {
    [super setUp];
    
    config = [testConfiguration objectForKey:@"BCMUserServiceTest"];
}

/**
 * Tests login and logout methods.
 */
- (void)testLoginAndLogout {
    NSError* error = nil;

    NSString* localAuthToken = [userService loginWith:[testConfiguration objectForKey:@"User"]
                                      andPassword:[testConfiguration objectForKey:@"Password"]
                                          asGroup:[NSNumber numberWithInteger:2]
                                                error:&error];
    STAssertNotNil(localAuthToken, @"Login failed (%@)", error);
    
    NSNumber* userId = [config objectForKey:@"logoutUserId"];

    BOOL loggedOut = [userService logout: userId withToken:localAuthToken error:&error];
    STAssertTrue(loggedOut, @"Logout failed (%@)", error);
}

/**
 * Tests that login attempt with incorrect credentials fails.
 */
- (void)testInvalidLogin {
    NSError* error = nil;
    
    NSString* localAuthToken = [userService loginWith:[testConfiguration objectForKey:@"User"]
                                      andPassword:@"invalid_password"
                                          asGroup:[NSNumber numberWithInteger:2]
                                            error:&error];    
    STAssertNil(localAuthToken, @"Login failed (%@)", error);
    STAssertNotNil(error, nil);
}

/**
 * Tests create user.
 */
-(void)testCreateUser
{
    NSNumber* userID = [config objectForKey:@"createUserId"];
    // remove test user if any
    [userService deleteUser:userID withToken:[self authToken] error:nil];
    
    // create test user
    NSError* error = nil;
    NSString* name = @"test_user";
    
    BCMUser* newUser = [userService user];
    newUser.email = @"test@test.com";
    newUser.employeeName = @"Test employee";
    newUser.username = name;
    newUser.id = userID;

    // post request and test results
    NSNumber* createdId = [userService createUser:newUser
                                        withToken:[self authToken]
                                            error:&error];
    STAssertNotNil(createdId, @"Could not create user (%@)", error);
    STAssertNil(error, @"Error detected when trying to create user (%@)", error);
    STAssertEqualObjects(createdId, userID, @"Wrong user ID returned: %i", createdId);
    // check if local store updated
    error = nil;
    BCMPagedResult *result =[managedObjectContext fetchObjectsForEntityName:@"BCMUser"
                                                              withPredicate:nil
                                                                   atOffset:0
                                                              withBatchSize:5
                                                                      error:&error];
    STAssertTrue(result.values.count == 1, @"Wrong number of entities found: %i", result.values.count);
    STAssertEqualObjects([result.values.lastObject username], name, @"Wrong object found in loca store");
    
    // cleanup test result
    error = nil;
    BOOL res = [userService deleteUser:userID withToken:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to clean user", error);
}

/**
 * Tests update user
 */
-(void)testUpdateUser
{
    // Create user first
    //
    NSNumber* userID = [config objectForKey:@"createUserId"];
    // remove test user if any
    [userService deleteUser:userID withToken:[self authToken] error:nil];
    
    // create test user
    NSError* error = nil;
    
    BCMUser* newUser = [userService user];
    newUser.email = @"test@test.com";
    newUser.employeeName = @"Test employee";
    newUser.username = @"test_user";
    newUser.id = userID;
    
    // post request and test results
    NSNumber* createdId = [userService createUser:newUser
                                        withToken:[self authToken]
                                            error:&error];
    STAssertNotNil(createdId, @"Could not create user (%@)", error);
    
    // now try to update
    //
    newUser.email =@"modified_email@test.com";
    error = nil;
    BOOL res = [userService updateUser:newUser withToken:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to update user, error (%@)", error);
    
    // cleanup test result
    error = nil;
    res = [userService deleteUser:userID withToken:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to clean user", error);
}

/**
 * Tests delete user.
 */
-(void)testDeleteUser
{
    NSNumber* userID = [config objectForKey:@"deleteUserId"];
    // remove test user if any
    [userService deleteUser:userID withToken:[self authToken] error:nil];
    
    // create test user
    NSError* error = nil;
    
    BCMUser* newUser = [userService user];
    newUser.email = @"test_delete@test.com";
    newUser.employeeName = @"Test employee delete";
    newUser.username = @"test_delete_user";
    newUser.id = userID;
    NSNumber* createdId = [userService createUser:newUser withToken:[self authToken]error:&error];
    STAssertNotNil(createdId, @"Could not create user to test delete user (%@)", error);
    
    // post delete request and check results
    BOOL deleted = [userService deleteUser:createdId
                                 withToken:[self authToken]
                                     error:&error];    
    STAssertTrue(deleted, @"Could not delete user (%@)", error);
    STAssertNil(error, @"Error detected when trying to delete user (%@)", error);

    // check if user was deleted localy
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BCMUser" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(id=%@)", userID];
    [request setPredicate:predicate];
    error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array != nil){
        STAssertTrue(array.count == 0, @"Failed to delete user loacly");
    }
}

/**
 * Tests delete non existent user.
 */
-(void)testDeleteNonExistentUser
{
    NSNumber* userId = [NSNumber numberWithInt: 1111111111];
    
    // delete non existed user
    NSError* error = nil;
    BOOL deleted = [userService deleteUser:userId withToken:[self authToken] error:&error];
    STAssertFalse(deleted, @"Could not delete user (%@)", error);
    STAssertNotNil(error, @"Error expected when trying to delete non existing user");
}

/**
 * Tests get users.
 */
-(void)testGetUsers
{
    NSError* error = nil;
    // get initial number of users if any
    BCMPagedResult* pRes = [userService getUsersWith:[self authToken] atStartCount:0 andPageSize:10 error:&error];
    STAssertNotNil(pRes, @"Paged result expected when testing users not found, error (@%)", error);
    int startCount = pRes.totalCount;
    
    // store TWO users
    NSDictionary* fixture = [self readFixture:@"BCMUser.json"];
    BCMUser* entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    entity.id = [NSNumber numberWithInt: 1101];
    
    entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                     inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    entity.id = [NSNumber numberWithInt: 1102];
    entity.username = @"test_user";
    
    // test results
    //
    int pageSize = 10;
    pRes = nil;
    STAssertNoThrow(pRes = [userService getUsersWith:[self authToken] atStartCount:0 andPageSize:pageSize error:&error], @"Error when trying to get users");
    STAssertNotNil(pRes, @"Paged result expected when testing get users");
    int count = startCount + 2;// we've added two users
    STAssertTrue(pRes.totalCount == count, @"Wrong total count returned: %i", pRes.totalCount);
    
    // check page size
    NSArray* users = pRes.values;
    STAssertNotNil(users, @"Set of users expected");
    if(startCount > pageSize){
        count = pageSize;
    }
    STAssertTrue(users.count == count, @"Wrong user's set size returned: %i", users.count);
}

/**
 * Tests search users.
 */
-(void)testSearchUsers
{
    NSError* error = nil;
    // get initial number of users if any
    BCMPagedResult* pRes = [userService searchUsersWith:[self authToken] forFilter:nil atStartCount:0 andPageSize:10 error:&error];
    STAssertNotNil(pRes, @"Paged result expected when testing users not found, error (%@)", error);
    int startCount = pRes.totalCount;
    
    // store TWO users for testing
    //
    NSDictionary* fixture = [self readFixture:@"BCMUser.json"];
    BCMUser* entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    entity.employeeName = @"John Smith";
    entity.id = [NSNumber numberWithInt: 1201];
    BCMUserGroup* group = [entity.groups anyObject];
    
    entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                     inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    entity.id = [NSNumber numberWithInt: 1202];
    entity.employeeName = @"John Doe";
    

    //
    // test results
    //
    // empty filter - all users returned
    error = nil;
    pRes = [userService searchUsersWith:[self authToken] forFilter:nil atStartCount:0 andPageSize:10 error:&error];
    STAssertNotNil(pRes, @"Failed to search users, error (%@)", error);
    int count = startCount + 2;//we have added 2 users
    STAssertTrue(pRes.totalCount == count, @"Wrong total count returned: %i", pRes.totalCount);
    
    // setup filter to return just one user
    //
    BCMUserSearchFilter* filter = [[[BCMUserSearchFilter alloc]init]autorelease];
    filter.userId = [NSNumber numberWithInt:1201];
    filter.employeeName = @"Smith";
    filter.userGroup = group;
    filter.rule = BCMFilterRuleAND;
    
    error = nil;
    pRes = [userService searchUsersWith:[self authToken] forFilter:filter atStartCount:0 andPageSize:10 error:&error];
    STAssertNotNil(pRes, @"Failed to search users, error (%@)", error);
    count = pRes.totalCount; 
    // only one result satisfying filtering criterion expected
    STAssertTrue(count == 1, @"Wrong total count returned: %i", count);
    NSArray* users = pRes.values;
    STAssertEqualObjects(@"John Smith", ((BCMUser*)[users lastObject]).employeeName, @"Wrong user found");
    
    // setup filter to return two users
    //
    filter.userId = [NSNumber numberWithInt:1202];
    filter.employeeName = @"Smith";
    filter.userGroup = nil;
    filter.rule = BCMFilterRuleOR;
    
    error = nil;
    pRes = [userService searchUsersWith:[self authToken] forFilter:filter atStartCount:0 andPageSize:10 error:&error];
    STAssertNotNil(pRes, @"Failed to search users, error (%@)", error);
    count = pRes.totalCount;
    STAssertTrue(count == 2, @"Wrong total count returned: %i", count);
    count = pRes.values.count;
    STAssertTrue(count == 2, @"Wrong number of resulting values returned: %i", count);    
}

/**
 * Tests users list refresh from remote web service endpoint
 */
-(void)testRefreshData{
    // remove all local users if any
    NSError* error = nil;
    BOOL res = [managedObjectContext deleteAllObjectsForEntityName:@"BCMUser" error:&error];
    STAssertTrue(res, @"Failed to delete all users, error (%@)", error);
    
    error = nil;
    NSArray *users = [managedObjectContext getObjectsForEntityName:@"BCMUser" withPredicate:nil sortDescriptors:nil error:&error];
    STAssertTrue(users.count == 0, @"All users expected to be deleted, error (%@)", error);
    
    // do refresh data
    //
    error = nil;
    res = [userService refreshData:[self authToken] error:&error];
    STAssertTrue(res, @"Failed to refresh users, error (%@)", error);
    
    // check if users stored localy
    error = nil;
    users = [managedObjectContext getObjectsForEntityName:@"BCMUser" withPredicate:nil sortDescriptors:nil error:&error];
    STAssertTrue(users.count > 0, @"Failed to add users from remote service, error (%@)", error);
}

@end
