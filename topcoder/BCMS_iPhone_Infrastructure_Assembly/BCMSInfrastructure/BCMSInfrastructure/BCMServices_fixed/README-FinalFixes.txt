The fixes were performed as suggested by the reviewers. Some details follow.

***** BCMIncidentAttachmentService.downloadIncidentAttachment *****
This API is broken as discussed here:
http://apps.topcoder.com/forums/?module=Thread&threadID=731495&start=0
Thus, corresponding test cases fail.

***** BCMIncidentAssociationService *****
All BCMIncidentAssociationService APIs are broken. This was reported here:
http://apps.topcoder.com/forums/?module=Thread&threadID=731597&start=0
Thus, corresponding test cases fail.

***** Parameter checking for input parameters *****
As discussed here: http://apps.topcoder.com/forums/?module=Thread&threadID=731947&start=0&mc=3#1473204
no need to change.

***** Logging *****
Error logging were added in multiple places.

***** Code documentation *****
All code documentation were copied from header files to implementation files as
requried by the reviewer. TCSASSEMBLER was replaced by read handle everywhere.

***** Unit tests *****
Unit tests were reorganized, new test were added to assure full test coverage.
Failure tests were added where possible. For your convenience, only service
tests relevant to this assembly were left enabled in XCode project.

***** Thread safety *****
Reviewer shen75 recommended managedObjectContext should be locked in service
class. However, Apple clearly advises against ever accessing MOC from multiple
threads at all. This issue had been discussed on the forum before:
http://apps.topcoder.com/forums/?module=Thread&threadID=731209&start=0
and the decision was to contract it to the frontend instead.

Alternatively, any thread that needs access service can create its local service
instance accessing its own MOC (as recommended by Apple). This doesn't require any
code change.

***** Other changes *****
Some minor issues reported by reviewers of related assemblies were addressed.
