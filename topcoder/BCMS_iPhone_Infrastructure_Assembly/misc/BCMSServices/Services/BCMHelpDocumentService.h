//
//  BCMHelpDocumentService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

@class BCMPagedResult;

/**
 * Service responsible for managing <code>BCMHelpDocument</code>s.
 * @author proxi
 * @version 1.0
 */
@interface BCMHelpDocumentService : BCMSService

/** Gets <code>BCMHelpDocument</code>s for given search text from the local persistence,
 * with given fetch size and fetch offset.
 * @param token Authentication token.
 * @param searchText Search text.
 * @param startCount Fetch offset.
 * @param pageSize Fetch size.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>BCMPagedResult</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (BCMPagedResult*)getHelpDocumentsWith:(NSString*)token
                          forSearchText:(NSString*)searchText
                           atStartCount:(NSUInteger)startCount
                            andPageSize:(NSUInteger)pageSize
                                  error:(NSError**)error;

/**
 * Loads the data for help document.
 * @param token Authentication token.
 * @param helpDocumentId Document id.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded <code>NSData</code> if operation succeeds, otherwise <code>nil</code>.
 */
- (NSData*)downloadHelpDocumentWith:(NSString*)token
                    forHelpDocument:(NSNumber*)helpDocumentId
                              error:(NSError**)error;

/**
 * Refresh all help documents entities from the server.
 * @param token Authentication token.
 * @param error If error occurs, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshData:(NSString*)token
              error:(NSError**)error;
@end
