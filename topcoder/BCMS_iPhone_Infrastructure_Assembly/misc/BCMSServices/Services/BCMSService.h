//
//  BCMSService.h
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

// Holds common defines for BCMServices framework
#define BCMS_DEBUG 1

//
// Logging Defines.
//
#define BCMServicesLog if(!BCMS_DEBUG); else NSLog

// The JSON object's name for error message
#define BCM_JSON_ERROR_MESSAGE_KEY @"ErrorMesssage"
// The JSON object's name for operation succeeded flag
#define BCM_JSON_OPERATION_SUCCESS_KEY @"OperationSucceeded"
// The JSON object's name for result object
#define BCM_JSON_REQUEST_RESULT_KEY @"Result"
// The JSON object's name for collection of results inside Result object
#define BCM_JSON_REQUEST_RESULTS_COLLECTION_KEY @"Results"
// The JSON object's name for gerenal purpose Id property
#define BCM_JSON_ID_KEY @"Id"
// The JSON object's name for totalCount property
#define BCM_JSON_TOTAL_COUNT_KEY @"TotalCount"
// The JSON object's key for created object ID
#define BCM_JSON_CREATED_ID_KEY @"CreatedId"
// The JSON object's key for data part of response
#define BCM_JSON_DATA_KEY @"Data"

// The date format
#define BCM_JSON_DATE_FORMAT @"yyyy-MM-dd"

@class NSManagedObject;
@class NSManagedObjectContext;
@class BCMPagedResult;

/**
 * Base service class.
 * @author proxi
 * @version 1.0
 */
@interface BCMSService : NSObject

/**
 * <code>NSManagedObjectContext</code> used by this service.
 */
@property (readonly) NSManagedObjectContext* managedObjectContext;

/**
 * Base URL of associated REST service.
 */
@property (readonly) NSURL* baseURL;

/**
 * URL of associated REST service.
 */
@property (readonly) NSURL* serviceURL;

/**
 * Designated constructor for service classes.
 * @param context <code>NSManagedObjectContext</code> to use.
 * @param baseURL Base URL of associated REST service.
 * @return The newly initialized service.
 */
- (id)initWithContext:(NSManagedObjectContext*)context
           andBaseURL:(NSURL*)baseURL;

/**
 * Serialized object to JSON data that can be posted to remote service.
 * @param object Object.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Serialized data.
 */
- (NSData*)serializeObject:(NSObject*)object
                     error:(NSError**)error;

/**
 * Sends raw request to remote service.
 * @param method HTTP method.
 * @param URL URL.
 * @param data Data to send.
 * @param contentType HTTP Content-Type.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Result from the service.
 */
- (id)remote:(NSString*)method
         URL:(NSURL*)URL
        data:(NSData*)data
 contentType:(NSString*)contentType
       error:(NSError**)error;

/**
 * Sends JSON request to remote service.
 * @param method HTTP method.
 * @param path Relative URI.
 * @param data Data to send.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Result from the service.
 */
- (id)remote:(NSString*)method
        path:(NSString*)path
        data:(NSData*)data
       error:(NSError**)error;

/**
 * Uploads data to the remote service.
 * @param data Data to upload.
 * @param path Relative URI.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Result from the service.
 */
- (id)upload:(NSData*)data
        path:(NSString*)path
       error:(NSError**)error;

/**
 * Downloads data from the remote service.
 * @param path Relative URI.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded data.
 */
- (NSData*)download:(NSString*)path
              token:(NSString*)token
              error:(NSError**)error;

/**
 * Creates object in the remote service. If successful, commits to local store.
 * @param object Object.
 * @param URI Resource identifier.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)createObject:(NSManagedObject*)object
                      URI:(NSString*)URI
                    token:(NSString*)token
                    error:(NSError**)error;
/**
 * Creates object in the remote service and adds it to the parent object specified by its entity name.
 * @param object Object.
 * @param to the parent object's entity name to accept created object
 * @param URI Resource identifier.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Id of the newly created entity if successful, otherwise <code>nil</code>.
 */
- (NSNumber*)addObject:(NSManagedObject*)object
                    to:(NSString*)entityName
                   URI:(NSString*)URI
                 token:(NSString*)token
                 error:(NSError**)error;

/**
 * Deletes object from the remote service. If successful, deletes from local store.
 * @param objectId Id of the object.
 * @param URI Resource identifier.
 * @param entityName Name of the entity.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)deleteObjectWithId:(NSNumber*)objectId
                       URI:(NSString*)URI
             forEntityName:(NSString*)entityName
                     token:(NSString*)token
                     error:(NSError**)error;

/**
 * Updates child object in the remote service. As response the remote service will return full parent
 * object definition with updated child. Thus response should be treated differently than when ordinary 
 * object updated. If successful, updates in local store.
 * @param object Object.
 * @param URI Resource identifier.
 * @param parentEntity the parent entity, which is returned from remote service as response.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)updateObject:(NSManagedObject*)object
                 URI:(NSString*)URI
          withParent:(NSString*)parentEntity
               token:(NSString*)token
               error:(NSError**)error;

/**
 * Refreshes paged data for specified entity by downloading fresh data from remote endpoint and storing it localy.
 * During the operation it will check last refresh time for specified entity and downloads only newest entities.
 *
 * N.B.: This refresh method is designed to perform refresh operations returning paged data from remote web service.
 * As result this method is in first turn try to attempt total number of entities on server and then by second request
 * will try to get them all in one request.
 *
 * It is sole responsibility of caller to remove previous data from local context if needed. As result of this
 * method execution new entities will be added, but existing will be not updated.
 * @param entity the entity name to be refreshed from remote endpoint
 * @param since the last refresh time for entity or <code>nil</code> to retrieve all entities
 * @param URI the URI part with entity resource identifier.
 * @param token the authentication token
 * @param error the error placeholder. Will contain instance of <code>NSError</code> that describes the problem in case of error.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshPagedDataForEntity:(NSString*)entity
                            since:(NSDate*)lastRefresh
                              URI:(NSString*)URI
                            token:(NSString*)token
                            error:(NSError**)error;

/**
 * Refreshes paged data for specified entity by downloading fresh data from remote endpoint and storing it localy.
 *
 * N.B.: This refresh method is designed to perform refresh operations returning paged data from remote web service.
 * As result this method is in first turn try to attempt total number of entities on server and then by second request
 * will try to get them all in one request.
 *
 * It is sole responsibility of caller to remove previous data from local context if needed. As result of this
 * method execution new entities will be added, but existing will be not updated.
 * @param entity the entity name to be refreshed from remote endpoint
 * @param URI the URI path with resource identifier and part of query string unique to this particular entity.
 * @param error the error placeholder. Will contain instance of <code>NSError</code> that describes the problem in case of error.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshPagedDataForEntity:(NSString*)entity
                              URI:(NSString*)URI
                            error:(NSError**)error;

/**
 * Refreshes non-paged data (plain list) for specified entity by downloading fresh data from remote endpoint and storing it localy.
 *
 * N.B.: This refresh method is designed to perform refresh operations returning plain list of entities in one bunch without
 * any paging semantics. It is primary targeted for small list of entity instances to be acquired from remote endpoint.
 *
 * It is sole responsibility of caller to remove previous data from local context if needed. As result of this
 * method execution new entities will be added, but existing will be not updated.
 * @param entity the entity name to be refreshed from remote endpoint
 * @param URI the URI path with resource identifier and part of query string unique to this particular entity.
 * @param error the error placeholder. Will contain instance of <code>NSError</code> that describes the problem in case of error.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)refreshDataForEntity:(NSString*)entity
                         URI:(NSString*)URI
                       error:(NSError**)error;
@end
