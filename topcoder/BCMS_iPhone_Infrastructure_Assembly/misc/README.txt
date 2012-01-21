Thank you for reviewing this submission.

This submission builds on project structure from previous assembly. Since three
service assembly projects are running in parallel, it also provides parts of
services from other assemblies:
http://apps.topcoder.com/forums/?module=Thread&threadID=731569&start=0

For you convenience, relevant classes and unit test are grouped in XCode project
based on assembly project they belong to.

During the project, many bugs and inconsistencies in existing API implementation were
discovered, and some major architectural changes were agreed upon. They are discusses
in project forums and documented below.

##### Changes to architecture #####

A1. Service base class was introduced and constructor URL parameter type was
changed to NSURL as discussed in the forum:
http://apps.topcoder.com/forums/?module=Thread&threadID=731328&start=0
http://apps.topcoder.com/forums/?module=Thread&threadID=731331&start=0

A2. Some parameter types were changed from int to NSUInteger as discussed in the
forum: http://apps.topcoder.com/forums/?module=Thread&threadID=731329&start=0

A3. All methods received NSError parameter as discussed in the forum:
http://apps.topcoder.com/forums/?module=Thread&threadID=731374&start=0

A4. refreshData methods was dropped from service classes. They will be replaced
by single API as discussed here:
http://apps.topcoder.com/forums/?module=Thread&threadID=731270&start=0 This API
is not implemented, so mock implementation is provided using
CacheUpdatesService.

##### Known bugs in REST API and architecture #####

B1. There is a spelling mistake in ErrorMesssage field of the response:
http://apps.topcoder.com/forums/?module=Thread&threadID=731488&start=0

B2. Some service errors, such as authentication errors, are incorrectly returned
in XML: http://apps.topcoder.com/forums/?module=Thread&threadID=731139&start=0

B3. BCMIncidentAssociationService.createIncidentAssociation is broken:
http://apps.topcoder.com/forums/?module=Thread&threadID=731597&start=0&mc=1#
1471690

B4. BCMAreaOffice, BCMConveneRoom and BCMIncidentCategory contact APIs are
broken: http://apps.topcoder.com/forums/?module=Thread&threadID=731579&start=0

B5. BCMUserService.logout API should take auth token not userId:
http://apps.topcoder.com/forums/?module=Thread&threadID=731480&start=0

B6. HelpDocumentService.downloadHelpDocument API is seemingly broken. Also,
endpoint is configured incorrectly (it should omit filename parameter).
http://apps.topcoder.com/forums/?module=Thread&threadID=731493&start=0

##### Changes to code from previous (Entities) assembly #####

E1. Helper method NSCompoundPredicateTypeFromBCMFilterRule was introduced in
BCMFilterRule.

E2. BCMPagedResult.values was changed to NSArray.

E3. NSManagedObject(JSON).toJSON was slightly altered to produce NSArrays in
place of NSSets

E4.
BCMPagedResult(JSON).pagedResultForEntityName:inManagedObjectContext:fromJSON:
was altered to be usable in service code

E5. Exception classes were removed.

E6. BCMSServicesTestCase was renamed to BCMSEntitiesTestCase and test were
modified accordingly.
