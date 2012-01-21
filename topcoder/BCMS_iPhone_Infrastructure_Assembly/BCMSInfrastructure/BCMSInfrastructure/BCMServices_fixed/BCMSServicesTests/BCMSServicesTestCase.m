//
//  BCMSServicesTestCase.m
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSServicesTestCase.h"

#import "SBJson.h"
#import "NSManagedObject+JSON.h"
#import "NSManagedObjectContext+Utility.h"
#import "BCMPagedResult.h"

@implementation BCMSServicesTestCase

@synthesize authToken;

/**
 * Set up environment for testing.
 */
- (void)setUp {
    [super setUp];

    // Setup service objects.
    NSURL* baseURL = [NSURL URLWithString:[testConfiguration objectForKey:@"ServiceBaseURL"]];
    incidentService = [[BCMIncidentService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    incidentUpdateService = [[BCMIncidentUpdateService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    incidentNoteService = [[BCMIncidentNoteService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    incidentAttachmentService = [[BCMIncidentAttachmentService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    incidentAssociationService = [[BCMIncidentAssociationService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];

    lookupService = [[BCMLookupService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    areaOfficeService = [[BCMAreaOfficeService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    incidentCategoryService = [[BCMIncidentCategoryService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    conveneRoomService = [[BCMConveneRoomService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];

    userService = [[BCMUserService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    helpDocumentService = [[BCMHelpDocumentService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    utilityService = [[BCMUtilityService alloc] initWithContext:managedObjectContext andBaseURL:baseURL];
    
    // Log in.
    NSError* loginError = nil;
    NSString* user = [testConfiguration objectForKey:@"User"];
    NSString* password = [testConfiguration objectForKey:@"Password"];
    NSNumber* group = [testConfiguration objectForKey:@"LogInAsGroup"];
    authToken = [[userService loginWith:user
                                      andPassword:password
                                          asGroup:group
                                            error:&loginError] retain];
    STAssertNotNil(authToken, @"Login failed (%@)", loginError);
}

/**
 * Tear down test environment.
 */
- (void)tearDown {
    [authToken release];
    
    [utilityService release]; utilityService = nil;
    [helpDocumentService release]; helpDocumentService = nil;
    [userService release]; userService = nil;
    
    [conveneRoomService release]; conveneRoomService = nil;
    [incidentCategoryService release]; incidentCategoryService = nil;
    [areaOfficeService release]; areaOfficeService = nil;
    [lookupService release]; lookupService = nil;

    [incidentAssociationService release]; incidentAssociationService = nil;
    [incidentAttachmentService release]; incidentAttachmentService = nil;
    [incidentNoteService release]; incidentNoteService = nil;
    [incidentUpdateService release]; incidentUpdateService = nil;
    [incidentService release]; incidentService = nil;

    [super tearDown];
}

/**
 * Helper method to get unique identifier.
 */
- (NSString*)makeUUID {
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) autorelease];
    CFRelease(uuidObject);
    return uuidStr;
}

/**
 * Helper method to get BCMContact from specified set by its numeric ID
 * @param set the NSSet to look through
 * @param objId the NSNumber with object id
 * @return found BCMContact or <code>nil</code> if nothing found
 */
- (BCMContact*)findBCMContactWithId: (NSNumber *)objId inSet: (NSSet*) set {
    for(BCMContact* c in set){
        if([c.id isEqual:objId]){
            return c;
        }
    }
    return nil;
}

- (NSManagedObject*)anyObjectForEnityName:(NSString*)entityName {
    NSArray* objects = [managedObjectContext getObjectsForEntityName:entityName
                                                       withPredicate:nil
                                                     sortDescriptors:nil
                                                               error:nil];
    return [objects count] ? [objects objectAtIndex:0] : nil;
}

- (BCMIncident*)anyIncident {
    return (BCMIncident*)[self anyObjectForEnityName:@"BCMIncident"];
}

- (BCMContact*)anyContact {
    return (BCMContact*)[self anyObjectForEnityName:@"BCMContact"];
}

- (BCMUser*)anyUser {
    return (BCMUser*)[self anyObjectForEnityName:@"BCMUser"];
}

- (BCMUserGroup*)anyUserGroup {
    return (BCMUserGroup*)[self anyObjectForEnityName:@"BCMUserGroup"];
}

- (BCMAreaOffice*)anyAreaOffice {
    return (BCMAreaOffice*)[self anyObjectForEnityName:@"BCMAreaOffice"];
}

- (BCMIncidentCategory*)anyIncidentCategory {
    return (BCMIncidentCategory*)[self anyObjectForEnityName:@"BCMIncidentCategory"];
}

- (BCMIncidentStatus*)anyIncidentStatus {
    return (BCMIncidentStatus*)[self anyObjectForEnityName:@"BCMIncidentStatus"];
}

- (BCMIncidentUpdate*)anyIncidentUpdate {
    return (BCMIncidentUpdate*)[self anyObjectForEnityName:@"BCMIncidentUpdate"];
}

- (BCMIncidentType*)anyIncidentType {
    return (BCMIncidentType*)[self anyObjectForEnityName:@"BCMIncidentType"];
}

- (BCMConveneRoom*)anyConveneRoom {
    return (BCMConveneRoom*)[self anyObjectForEnityName:@"BCMConveneRoom"];
}

@end
