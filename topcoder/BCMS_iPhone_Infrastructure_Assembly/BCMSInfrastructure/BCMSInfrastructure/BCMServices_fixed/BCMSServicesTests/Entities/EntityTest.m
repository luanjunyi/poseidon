//
//  EntityTest.m
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "EntityTest.h"

#import "BCMSEntities.h"

@implementation EntityTest

/**
 * Tests <code>fromJSON</code> for <code>BCMHelpDocument</code> entity.
 */
- (void)testBCMHelpDocumentFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMHelpDocument.json"];

    BCMHelpDocument* entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];

    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"Name #29", @"Invalid property value");
    STAssertEqualObjects(entity.downloadLink, @"de3b254a-fdca-4eae-abc2-af6b28756d4b/helpDocuments/2", @"Invalid property value");
    STAssertEqualObjects(entity.searchText, @"SearchText #29", @"Invalid property value");
    STAssertEqualObjects(entity.documentShortDescription, @"ShortDescription #29", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMHelpDocument</code> entity.
 */
- (void)testBCMHelpDocumentToJson {
    BCMHelpDocument* entity = (BCMHelpDocument*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMHelpDocument"
                                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.name = @"name";
    entity.downloadLink = @"link";
    entity.searchText = @"searchText";
    entity.documentShortDescription = @"documentShortDescription";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:2], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"DownloadLink"], @"link", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"SearchText"], @"searchText", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"ShortDescription"], @"documentShortDescription", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMUserGroup</code> entity.
 */
- (void)testBCMUserGroupFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMUserGroup.json"];
    
    BCMUserGroup* entity = (BCMUserGroup*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUserGroup"
                                                                        inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"Company Security", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMUserGroup</code> entity.
 */
- (void)testBCMUserGroupToJson {
    BCMUserGroup* entity = (BCMUserGroup*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUserGroup"
                                                                        inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:2], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMUser</code> entity.
 */
- (void)testBCMUserFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMUser.json"];
    
    BCMUser* entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
    STAssertEqualObjects(entity.email, @"user20@test.com", @"Invalid property value");
    STAssertEqualObjects(entity.employeeName, @"EmployeeName #20", @"Invalid property value");
    STAssertEqualObjects(entity.username, @"user20", @"Invalid property value");

    STAssertEquals([entity.groups count], 6U, @"Invalid property value");

    BOOL hasUserGroup3 = NO;
    for (BCMUserGroup* userGroup in [entity.groups allObjects]) {
        if ([userGroup.id isEqual:[NSNumber numberWithInteger:3]]) {
            hasUserGroup3 = YES;
            STAssertEqualObjects(userGroup.name, @"Incident Situation Manager", @"Invalid property value");
        }
    }
    STAssertTrue(hasUserGroup3, @"Missing object");
}

/**
 * Tests <code>toJSON</code> for <code>BCMUserGroup</code> entity.
 */
- (void)testBCMUserToJson {
    BCMUser* entity = (BCMUser*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMUser"
                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.email = @"email";
    entity.employeeName = @"employeeName";
    entity.username = @"username";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:2], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Email"], @"email", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"EmployeeName"], @"employeeName", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Username"], @"username", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentUpdate</code> entity.
 */
- (void)testBCMIncidentUpdateFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentUpdate.json"];
    
    BCMIncidentUpdate* entity = (BCMIncidentUpdate*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentUpdate"
                                                                                  inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(entity.alertSent, [NSNumber numberWithBool:YES], @"Invalid property value");
    STAssertEqualObjects(entity.comment, @"Comment #2", @"Invalid property value");
    STAssertEqualObjects(entity.updatedBy, @"UpdatedBy #2", @"Invalid property value");    
    STAssertEqualObjects(entity.updatedDate, [NSDate dateWithTimeIntervalSince1970:1323065228], @"Invalid property value");
    STAssertEqualObjects(entity.incidentId, [NSNumber numberWithInteger:1], @"Invalid property value");

    STAssertEquals([entity.groups count], 1U, @"Invalid property value");
    BCMUserGroup* userGroup = (BCMUserGroup*)[entity.groups anyObject];
    STAssertEqualObjects(userGroup.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(userGroup.name, @"Company Security", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentUpdate</code> entity.
 */
- (void)testBCMIncidentUpdateToJson {
    BCMIncidentUpdate* entity = (BCMIncidentUpdate*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentUpdate"
                                                                                  inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.alertSent = [NSNumber numberWithBool:YES];
    entity.comment = @"comment";
    entity.incidentId = [NSNumber numberWithInteger:1];
    entity.updatedBy = @"updatedBy";
    entity.updatedDate = [NSDate dateWithTimeIntervalSince1970:1323065228];

    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:2], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"AlertSent"], [NSNumber numberWithBool:YES], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Comment"], @"comment", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"IncidentId"], [NSNumber numberWithInteger:1], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"UpdatedBy"], @"updatedBy", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"UpdatedDate"], @"/Date(1323065228000)/", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMContact</code> entity.
 */
- (void)testBCMContactFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMContact.json"];
    
    BCMContact* entity = (BCMContact*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMContact"
                                                                    inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:21], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"Contact #21", @"Invalid property value");
    STAssertEqualObjects(entity.primaryNumber, @"PrimaryNumber #21", @"Invalid property value");    
    STAssertEqualObjects(entity.secondaryNumber, @"SecondaryNumber #21", @"Invalid property value");

    STAssertTrue([entity.role isKindOfClass: [BCMContactRole class]], @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMContact</code> entity.
 */
- (void)testBCMContactToJson {
    BCMContact* entity = (BCMContact*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMContact"
                                                                    inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:2];
    entity.name = @"name";
    entity.primaryNumber = @"primaryNumber";
    entity.secondaryNumber = @"secondaryNumber";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:2], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"PrimaryNumber"], @"primaryNumber", @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"SecondaryNumber"], @"secondaryNumber", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMContactRole</code> entity.
 */
- (void)testBCMContactRoleFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMContactRole.json"];
    
    BCMContactRole* entity = (BCMContactRole*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMContactRole"
                                                                            inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"Secondary", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMContactRole</code> entity.
 */
- (void)testBCMContactRoleToJson {
    BCMContactRole* entity = (BCMContactRole*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMContactRole"
                                                                            inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentNote</code> entity.
 */
- (void)testBCMIncidentNoteFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentNote.json"];
    
    BCMIncidentNote* entity = (BCMIncidentNote*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentNote"
                                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:7], @"Invalid property value");
    STAssertEqualObjects(entity.note, @"Note #2", @"Invalid property value");
    STAssertEqualObjects(entity.addedBy, @"AddedBy #2", @"Invalid property value");
    STAssertEqualObjects(entity.addedDate, [NSDate dateWithTimeIntervalSince1970:1325653321], @"Invalid property value");
    STAssertEqualObjects(entity.incidentId, [NSNumber numberWithInteger:5], @"Invalid property value");
    STAssertEquals([entity.groups count], 0U, @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentNote</code> entity.
 */
- (void)testBCMIncidentNoteToJson {
    BCMIncidentNote* entity = (BCMIncidentNote*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentNote"
                                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.note = @"note";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Note"], @"note", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncident</code> entity.
 */
- (void)testBCMIncidentFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncident.json"];
    
    BCMIncident* entity = (BCMIncident*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncident"
                                                                      inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];

    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(entity.incident, @"Incident #50", @"Invalid property value");
    STAssertEqualObjects(entity.incidentNumber, [NSNumber numberWithInteger:50], @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncident</code> entity.
 */
- (void)testBCMIncidentToJson {
    BCMIncident* entity = (BCMIncident*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncident"
                                                                      inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.incident = @"incident";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Incident"], @"incident", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMConveneRoom</code> entity.
 */
- (void)testBCMConveneRoomFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMConveneRoom.json"];
    
    BCMConveneRoom* entity = (BCMConveneRoom*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMConveneRoom"
                                                                            inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"ConveneRoom #7", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMConveneRoom</code> entity.
 */
- (void)testBCMConveneRoomToJson {
    BCMConveneRoom* entity = (BCMConveneRoom*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMConveneRoom"
                                                                            inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentAssociation</code> entity.
 */
- (void)testBCMIncidentAssociationFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentAssociation.json"];
    
    BCMIncidentAssociation* entity = (BCMIncidentAssociation*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentAssociation"
                                                                                            inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    // IncidentAssociationService#GetIncidentAssociations does not return Id.
    //STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentAssociation</code> entity.
 */
- (void)testBCMIncidentAssociationToJson {
    BCMIncidentAssociation* entity = (BCMIncidentAssociation*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentAssociation"
                                                                                            inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentCategory</code> entity.
 */
- (void)testBCMIncidentCategoryFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentCategory.json"];
    
    BCMIncidentCategory* entity = (BCMIncidentCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentCategory"
                                                                                      inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentCategory</code> entity.
 */
- (void)testBCMIncidentCategoryToJson {
    BCMIncidentCategory* entity = (BCMIncidentCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentCategory"
                                                                                      inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMAreaOffice</code> entity.
 */
- (void)testBCMAreaOfficeFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMAreaOffice.json"];
    
    BCMAreaOffice* entity = (BCMAreaOffice*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMAreaOffice"
                                                                          inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:2], @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMAreaOffice</code> entity.
 */
- (void)testBCMAreaOfficeToJson {
    BCMAreaOffice* entity = (BCMAreaOffice*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMAreaOffice"
                                                                          inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentStatus</code> entity.
 */
- (void)testBCMIncidentStatusFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentStatus.json"];
    
    BCMIncidentStatus* entity = (BCMIncidentStatus*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentStatus"
                                                                                  inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:3], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"Closed", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentStatus</code> entity.
 */
- (void)testBCMIncidentStatusToJson {
    BCMIncidentStatus* entity = (BCMIncidentStatus*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentStatus"
                                                                                  inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentType</code> entity.
 */
- (void)testBCMIncidentTypeFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentType.json"];
    
    BCMIncidentType* entity = (BCMIncidentType*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentType"
                                                                              inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:3], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"IncidentType #3", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentType</code> entity.
 */
- (void)testBCMIncidentTypeToJson {
    BCMIncidentType* entity = (BCMIncidentType*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentType"
                                                                              inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMIncidentAttachement</code> entity.
 */
- (void)testBCMIncidentAttachmentFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMIncidentAttachment.json"];
    
    BCMIncidentAttachment* entity = (BCMIncidentAttachment*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentAttachment"
                                                                                          inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(entity.addedBy, @"AddedBy #2", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMIncidentAttachement</code> entity.
 */
- (void)testBCMIncidentAttachmentToJson {
    BCMIncidentAttachment* entity = (BCMIncidentAttachment*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMIncidentAttachment"
                                                                                          inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.addedBy = @"addedBy";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"AddedBy"], @"addedBy", @"Value incorrectly serialized");
}

/**
 * Tests <code>fromJSON</code> for <code>BCMAdditionalInfo</code> entity.
 */
- (void)testBCMAdditionalInfoFromJson {
    NSDictionary* fixture = [self readFixture:@"BCMAdditionalInfo.json"];
    
    BCMAdditionalInfo* entity = (BCMAdditionalInfo*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMAdditionalInfo"
                                                                                  inManagedObjectContext:managedObjectContext];
    [entity fromJSON:fixture];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInteger:1], @"Invalid property value");
    STAssertEqualObjects(entity.name, @"AddInfo #1", @"Invalid property value");
}

/**
 * Tests <code>toJSON</code> for <code>BCMAdditionalInfo</code> entity.
 */
- (void)testBCMAdditionalInfoToJson {
    BCMAdditionalInfo* entity = (BCMAdditionalInfo*)[NSEntityDescription insertNewObjectForEntityForName:@"BCMAdditionalInfo"
                                                                                  inManagedObjectContext:managedObjectContext];
    entity.id = [NSNumber numberWithInteger:42];
    entity.name = @"name";
    
    NSDictionary* data = [entity toJSON];
    
    STAssertEqualObjects([data objectForKey:@"Id"], [NSNumber numberWithInteger:42], @"Value incorrectly serialized");
    STAssertEqualObjects([data objectForKey:@"Name"], @"name", @"Value incorrectly serialized");
}

@end
