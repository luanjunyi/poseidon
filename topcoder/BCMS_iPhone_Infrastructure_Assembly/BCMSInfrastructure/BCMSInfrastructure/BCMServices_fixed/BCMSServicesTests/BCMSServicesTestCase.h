//
//  BCMSServicesTestCase.h
//  BCMSServicesTests
//
//  Created by proxi on 11-12-10.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSEntitiesTestCase.h"

#import "BCMSServices.h"

/**
 * Base class for test cases in the module. Sets up test environment and provides
 * helper methods.
 */
@interface BCMSServicesTestCase : BCMSEntitiesTestCase {
    BCMIncidentService* incidentService;
    BCMIncidentUpdateService* incidentUpdateService;
    BCMIncidentNoteService* incidentNoteService;
    BCMIncidentAttachmentService* incidentAttachmentService;
    BCMIncidentAssociationService* incidentAssociationService;

    BCMLookupService* lookupService;
    BCMAreaOfficeService* areaOfficeService;
    BCMIncidentCategoryService* incidentCategoryService;
    BCMConveneRoomService* conveneRoomService;

    BCMUserService* userService;
    BCMHelpDocumentService* helpDocumentService;
    BCMUtilityService* utilityService;
}

/**
 * Authentication token obtained during test setup.
 */
@property (readonly) NSString* authToken;

/**
 * Helper method to get unique identifier.
 */
- (NSString*)makeUUID;

/**
 * Helper method to get BCMContact from specified set by its numeric ID
 * @param set the NSSet to look through
 * @param objId the NSNumber with object id
 * @return found BCMContact or <code>nil</code> if nothing found
 */
- (BCMContact*)findBCMContactWithId: (NSNumber *)objId inSet: (NSSet*) set;

- (BCMIncident*)anyIncident;

- (BCMContact*)anyContact;

- (BCMUser*)anyUser;

- (BCMUserGroup*)anyUserGroup;

- (BCMAreaOffice*)anyAreaOffice;

- (BCMIncidentCategory*)anyIncidentCategory;

- (BCMIncidentStatus*)anyIncidentStatus;

- (BCMIncidentUpdate*)anyIncidentUpdate;

- (BCMIncidentType*)anyIncidentType;

- (BCMConveneRoom*)anyConveneRoom;

@end
