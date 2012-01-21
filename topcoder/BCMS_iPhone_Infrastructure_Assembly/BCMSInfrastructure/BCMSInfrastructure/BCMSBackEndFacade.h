//
//  BCMSBackEndFacade.h
//  BCMSInfrastructure
//
//  Created by luanjunyi on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCMSService.h"
#import "BCMConveneRoom.h"
#import "BCMHelpDocument.h"
#import "BCMIncidentAttachment.h"

@interface BCMSBackEndFacade : NSObject

-(BCMConveneRoom *)getConveneRooms:(NSString *)authToken startCount:(int)startCount pageSize:(int)pageSize;
-(BOOL)deleteConveneRoom:(NSString *)authToken roomId:(NSString *)roomId;
-(BCMHelpDocument *)getHelpDocument:(NSString *)authToken searchText:(NSString *)searchText startCount:(int)startCount pageSize:(int)pageSize;
-(NSSet *)getIncidentAttachments:(NSString *)authToken incidentId:(NSNumber *)incidentId;
-(BCMIncidentAttachment *)uploadIncidentAttachment:(NSString *)authToken incidentId:(NSNumber *)incidentId url:(NSURL *)url;
-(BOOL) deleteIncidentAttachment:(NSString *)authToken incidentAttachmentId:(NSNumber *)incidentAttachmentId;




@end
