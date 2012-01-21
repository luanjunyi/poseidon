//
//  BCMSService.m
//  BCMSServices
//
//  Created by proxi on 11-12-21.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMSService.h"

#import <CoreData/CoreData.h>
#import "SBJson.h"
#import "NSManagedObject+JSON.h"
#import "BCMSServiceError.h"

@implementation BCMSService

@synthesize managedObjectContext = _managedObjectContext;
@synthesize baseURL = _baseURL;
@synthesize serviceURL = _serviceURL;

/**
 * Designated constructor for service classes.
 * @param context <code>NSManagedObjectContext</code> to use.
 * @param baseURL Base URL of associated REST service.
 * @return The newly initialized service.
 */
- (id)initWithContext:(NSManagedObjectContext*)context
           andBaseURL:(NSURL*)baseURL {
    if (self = [super init]) {
        _managedObjectContext = [context retain];
        _baseURL = [baseURL retain];
        _serviceURL = [[NSURL URLWithString:[NSString stringWithFormat:@"%@.svc/", [NSStringFromClass([self class]) substringFromIndex:3]] relativeToURL:baseURL] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_serviceURL release];
    [_baseURL release];
    [_managedObjectContext release];
    
    [super dealloc];
}

/**
 * Serialized object to JSON data that can be posted to remote service.
 * @param object Object.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Serialized data.
 */
- (NSData*)serializeObject:(NSObject*)object
                     error:(NSError**)error {    
    if (error) {
        *error = nil;
    }
    
    NSObject* serialization = nil;
    if ([object isKindOfClass:[NSManagedObject class]]) {
        serialization = [(NSManagedObject*)object toJSON];
    } else if ([object isKindOfClass:[NSSet class]]) {
        NSMutableArray* children = [NSMutableArray array];
        for (NSManagedObject* child in (NSSet*)object) {
            [children addObject:[child toJSON]];
        }
        serialization = children;
    }
    
    SBJsonWriter* jsonWriter = [[[SBJsonWriter alloc] init] autorelease];
    NSError* serializationError = nil;
    NSString* jsonString = [jsonWriter stringWithObject:serialization error:&serializationError];
    if (!jsonString) {
        if (error) {
            *error = serializationError;
        }
        return nil;
    }
    
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 * Deserializes object from JSON representation.
 * @param object Object instance to populate.
 * @param result JSON dictionary to read from.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Deserialized instance, or <code>nil</code> if error occured.
 */
- (NSManagedObject*)deserializeObject:(NSManagedObject*)object
                             fromData:(NSDictionary*)result
                                error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    if (![result isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:BCMSServiceErrorDomain code:kBCMSServiceRemoteError userInfo:nil];
        }
        return nil;
    }
    
    [object fromJSON:result];
    
    return object;
}

/**
 * Parses service response, extracting result and error message.
 * @param data Response to parse.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Result from the service.
 */
- (id)parseServiceResponse:(NSData*)data error:(NSError**)error {
    if (error) {
        *error = nil;
    }

    NSString* jsonString = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];

    SBJsonParser* jsonParser = [[[SBJsonParser alloc] init] autorelease];
    
    NSError* jsonError = nil;
    NSDictionary* jsonResponse = [jsonParser objectWithString:jsonString error:&jsonError];
    if (!jsonResponse) {
        BCMServicesLog(@"BCMSService(parseServiceResponse:error:): Error parsing response (%@)", jsonError);
        if (error) {
            *error = jsonError;
        }
        return nil;
    }
    
    NSNumber* operationSucceeded = (NSNumber*)[jsonResponse objectForKey:BCM_JSON_OPERATION_SUCCESS_KEY];
    if (![operationSucceeded boolValue]) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [jsonResponse objectForKey:BCM_JSON_ERROR_MESSAGE_KEY], NSLocalizedDescriptionKey,
                                  nil];
        NSError* remoteError = [NSError errorWithDomain:BCMSServiceErrorDomain code:kBCMSServiceRemoteError userInfo:userInfo];
        if (error) {
            *error = remoteError;
        }
        BCMServicesLog(@"BCMSService(parseServiceResponse:error:): Remote error (%@)", remoteError);
    }
    
    return [jsonResponse objectForKey:BCM_JSON_REQUEST_RESULT_KEY];
}

/**
 * Sends synchronous HTTP request.
 * @param method HTTP method.
 * @param contentType Content-Type header.
 * @param data Data to send as request body.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Body of the response.
 */
- (NSData*)sendSynchronousRequest:(NSURL*)URL
                       withMethod:(NSString*)method
                      contentType:(NSString*)contentType
                             data:(NSData*)data
                            error:(NSError**)error {
    if (error) {
        *error = nil;
    }

    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:URL
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:20];
    urlRequest.HTTPMethod = method;
    urlRequest.HTTPBody = data;
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSError* networkError = nil;
    NSHTTPURLResponse* response = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&networkError];
    if (networkError) {
        BCMServicesLog(@"BCMSService(sendSynchronousRequest:): Network error (%@)", networkError);
        if (error) {
            *error = networkError;
        }
        return nil;
    }
    
    if (response.statusCode != 200) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"Invalid HTTP response code (%ld, HTTP %@)", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]], NSLocalizedDescriptionKey,
                                  nil];
        NSError* httpError = [NSError errorWithDomain:BCMSServiceErrorDomain code:kBCMSServiceRemoteError userInfo:userInfo];

        BCMServicesLog(@"BCMSService(sendSynchronousRequest:): HTTP error (%@)", httpError);
        if (error) {
            *error = httpError;
        }
        return nil;
    }

    return responseData;
}

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
       error:(NSError**)error {
    
    BCMServicesLog(@"BCMSService(remote:path:data:error:): %@ %@", method, [URL absoluteString]);
    
    if (error) {
        *error = nil;
    }

    NSError* networkError = nil;
    NSData* responseData = [self sendSynchronousRequest:URL
                                             withMethod:method
                                            contentType:contentType
                                                   data:data
                                                  error:&networkError];
    if (networkError) {
        if (error) {
            *error = networkError;
        }
        
        return nil;
    }

    NSError* responseError = nil;
    id result = [self parseServiceResponse:responseData error:&responseError];
    if (responseError) {
        if (error) {
            *error = responseError;
        }
        
        return nil;
    }
    
    return result;
}

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
       error:(NSError**)error {
    NSURL* URL = [NSURL URLWithString:[@"json/" stringByAppendingString:path] relativeToURL:self.serviceURL];

    return [self remote:method
                    URL:URL
                   data:data
            contentType:@"text/json"
                  error:error];
}

/**
 * Uploads data to the remote service.
 * @param data Data to upload.
 * @param path Relative URI.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Result from the service.
 */
- (id)upload:(NSData*)data
        path:(NSString*)path
       error:(NSError**)error {
    NSURL* URL = [NSURL URLWithString:[@"json/" stringByAppendingString:path] relativeToURL:self.serviceURL];

    return [self remote:@"POST"
                    URL:URL
                   data:data
            contentType:nil
                  error:error];
}

/**
 * Downloads data from the remote service.
 * @param path Relative URI.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return Downloaded data.
 */
- (NSData*)download:(NSString*)path
              token:(NSString*)token
              error:(NSError**)error {
    NSURL* URL;
    if([token length] > 0){
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", token, path] relativeToURL:self.serviceURL];
    }else{
        URL = [NSURL URLWithString:path relativeToURL:self.serviceURL];
    }

    return [self sendSynchronousRequest:URL
                             withMethod:@"GET"
                            contentType:nil
                                   data:nil
                                  error:error];
}

/**
 * Deletes object with given id from local store.
 * @param objectId Object id.
 * @param entityName Entity name.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)deleteLocalObjectWithId:(NSNumber*)objectId
                  forEntityName:(NSString*)entityName
                          error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %@", objectId];

    NSError* fetchError = nil;
    
    NSArray* items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if ([items count] == 0) {
        BCMServicesLog(@"BCMSService(deleteLocalObjectWithId:forEntityName:error:): Error fetching %@", fetchError);
        if (error) {
            *error = fetchError;
        }

        return NO;
    }
    
    NSManagedObject* localObject = (NSManagedObject*)[items objectAtIndex:0];    

    [self.managedObjectContext deleteObject:localObject];

    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMSService(deleteLocalObjectWithId:forEntityName:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        return NO;
    }
    
    return YES;
}

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
                    error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Serialize object.
    NSError* serializationError = nil;
    NSData* objectData = [self serializeObject:object error:&serializationError];
    if (!objectData) {
        if (error) {
            *error = serializationError;
        }
        [self.managedObjectContext deleteObject:object];
        return nil;
    }
    
    BCMServicesLog(@"BCMSService(createObject:URI:token:error:): Object to create %@", [[[NSString alloc]initWithData:objectData encoding:NSUTF8StringEncoding]autorelease]);

    // Post serialized object to server.
    NSError* remoteError = nil;
    NSDictionary* result = [self remote:@"POST"
                                   path:[NSString stringWithFormat:@"%@/%@", token, URI]
                                   data:objectData
                                  error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        [self.managedObjectContext deleteObject:object];
        return nil;
    }

    // Deserialize returned object.
    NSError* deserializeError = nil;
    NSManagedObject* createdObject = [self deserializeObject:object
                                                    fromData:result
                                                       error:&deserializeError];
    BCMServicesLog(@"BCMSService(createObject:URI:token:error:): Created remote object %@", [createdObject toJSON]);
    if (!createdObject) {
        if (error) {
            *error = deserializeError;
        }
        [self.managedObjectContext deleteObject:object];
        return nil;
    }
    
    // Commit store.
    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMSService(createObject:URI:token:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        [self.managedObjectContext deleteObject:object];
        return nil;
    }

    return (NSNumber*)[createdObject valueForKey:@"id"];
}

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
                 error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Serialize object.
    NSError* serializationError = nil;
    NSData* objectData = [self serializeObject:object error:&serializationError];
    if (!objectData) {
        if (error) {
            *error = serializationError;
        }
        return nil;
    }
    
    BCMServicesLog(@"BCMSService(addObject:to:URI:token:error:): Object to add %@", [[[NSString alloc]initWithData:objectData encoding:NSUTF8StringEncoding]autorelease]);
    
    // remove placeholder object to avoid garbage in local context
    [self.managedObjectContext deleteObject:object];
    
    // Post serialized object to server.
    //
    NSError* remoteError = nil;
    NSDictionary* result = [self remote:@"POST"
                                   path:[NSString stringWithFormat:@"%@/%@", token, URI]
                                   data:objectData
                                  error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return nil;
    }
    
    // get response data
    NSDictionary* responseData = [result objectForKey:BCM_JSON_DATA_KEY];
    BCMServicesLog(@"BCMSService(addObject:to:URI:token:error:): add response %@", responseData);
    
    // Deserialize returned data into local context.    
    NSManagedObject* createdObject = [NSManagedObject objectForEntityForName:entityName 
                                                      inManagedObjectContext:self.managedObjectContext 
                                                                    fromJSON:responseData];

    if (!createdObject) {
        [self.managedObjectContext deleteObject:object];
        return nil;
    }
    
    // Commit store.
    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMSService(addObject:to:URI:token:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        return nil;
    }
    
    return [result valueForKey:BCM_JSON_CREATED_ID_KEY];
}

/**
 * Updates object in the remote service. As response the remote service may return full parent
 * object definition with updated child object. Thus response should be treated differently than when ordinary 
 * object updated. If successful, updates in local store.
 * @param object Object.
 * @param URI Resource identifier.
 * @param parentEntity the parent entity, which is returned from remote service as response or <code>nil</code>
 * if there is no parent entity.
 * @param token Authentication token.
 * @param error If error occured, contains instance of <code>NSError</code> that describes the problem.
 * @return <code>YES</code> if operation succeeds, otherwise <code>NO</code>.
 */
- (BOOL)updateObject:(NSManagedObject*)object
                 URI:(NSString*)URI
          withParent:(NSString*)parentEntity
               token:(NSString*)token
               error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // Serialize object.
    NSError* serializationError = nil;
    NSData* objectData = [self serializeObject:object error:&serializationError];
    
    BCMServicesLog(@"BCMSService(updateObject:URI:token:error:): Object %@", [[[NSString alloc]initWithData:objectData encoding:NSUTF8StringEncoding]autorelease]);
    if (!objectData) {
        if (error) {
            *error = serializationError;
        }
        return NO;
    }
    
    // Post serialized object to server.
    NSError* remoteError = nil;
    NSDictionary* result = [self remote:@"PUT"
                                   path:[NSString stringWithFormat:@"%@/%@", token, URI]
                                   data:objectData
                                  error:&remoteError];
    BCMServicesLog(@"BCMSService(updateObject:URI:token:error:): Response %@", result);
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // Deserialize returned object.
    NSError* deserializeError = nil;
    NSManagedObject* createdObject;
    if(parentEntity != nil){
        // the full parent object returned
        createdObject = [NSManagedObject objectForEntityForName:parentEntity 
                                         inManagedObjectContext:self.managedObjectContext 
                                                       fromJSON:result];
    }else{
        // only updated object returned
        createdObject = [self deserializeObject:object
                                       fromData:result
                                          error:&deserializeError];
    }
    BCMServicesLog(@"BCMSService(updateObject:URI:token:error:):updated object %@", [createdObject toJSON]);
    if (!createdObject) {
        if (error) {
            *error = deserializeError;
        }
        return NO;
    }
    
    // Commit store.
    NSError* saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        BCMServicesLog(@"BCMSService(updateObject:URI:token:error:): Error saving %@", saveError);
        if (error) {
            *error = saveError;
        }
        return NO;
    }
    
    return YES;
}

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
                     error:(NSError**)error {
    if (error) {
        *error = nil;
    }

    NSError* remoteError = nil;
    NSNumber* result = [self remote:@"DELETE"
                               path:[NSString stringWithFormat:@"%@/%@", token, URI]
                               data:nil
                              error:&remoteError];
    if (![result boolValue]) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }

    // Successfully deleted remotely, now delete from local store.
    return [self deleteLocalObjectWithId:objectId
                           forEntityName:entityName
                                   error:error];
}


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
                            error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    // adjust last refresh
    if(lastRefresh == nil){
        // set last refresh as reference time begin
        lastRefresh = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    }
    // format last refresh
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:BCM_JSON_DATE_FORMAT];
    NSString *formattedLastRefresh = [dateFormatter stringFromDate:lastRefresh];
    
    NSError* remoteError = nil;
    // Get total count of new entities on remote service
    //
    NSString* uriStr = [NSString stringWithFormat:@"%@&date=%@&startCount=1&pageSize=1", URI, formattedLastRefresh];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"CacheUpdatesService.svc/json/%@/updates/%@", token, uriStr] relativeToURL:self.baseURL];
    NSDictionary* result = [self remote:@"GET"
                                    URL:url
                                   data:nil
                            contentType:nil
                                  error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }

    NSNumber* totalCount = [result objectForKey:BCM_JSON_TOTAL_COUNT_KEY];
    if(totalCount == 0){
        // nothing to refresh, but it's not an error
        return YES;
    }
    
    // get all entities from remote endpoint
    //    
    remoteError = nil;
    uriStr = [NSString stringWithFormat:@"%@&date=%@&startCount=1&pageSize=%i", URI, formattedLastRefresh, [totalCount intValue]];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"CacheUpdatesService.svc/json/%@/updates/%@", token, uriStr] relativeToURL:self.baseURL];
    result = [self remote:@"GET"
                      URL:url
                     data:nil
              contentType:nil
                    error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // Store entities localy
    //
    NSArray* resultList = [result objectForKey:BCM_JSON_REQUEST_RESULTS_COLLECTION_KEY];
    if(resultList.count > 0){
        // iterate over received objects and store data
        [self.managedObjectContext lock];
        for(NSDictionary* json in resultList){
            // insert object into context
            [NSManagedObject objectForEntityForName:entity 
                             inManagedObjectContext:self.managedObjectContext 
                                           fromJSON:json];
        }
        [self.managedObjectContext unlock];
    }
    // no errors detected
    return YES;
}

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
                            error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSError* remoteError = nil;
    // Get total count of users on remote service
    //
    NSString* uriStr = [URI stringByAppendingString:@"&startCount=1&pageSize=1"];
    NSDictionary* result = [self remote:@"GET"
                                   path:uriStr
                                   data:nil
                                  error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    NSNumber* totalCount = [result objectForKey:BCM_JSON_TOTAL_COUNT_KEY];
    if(totalCount == 0){
        // nothing to refresh, but it's not an error
        return YES;
    }
    
    // get all entities from remote endpoint
    //
    remoteError = nil;
    uriStr = [URI stringByAppendingString:[NSString stringWithFormat:@"&startCount=1&pageSize=%i", [totalCount intValue]]];
    result = [self remote:@"GET"
                     path:uriStr
                     data:nil
                    error:&remoteError];
    if (!result) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // Store entities localy
    //
    NSArray* resultList = [result objectForKey:BCM_JSON_REQUEST_RESULTS_COLLECTION_KEY];
    if(resultList.count > 0){
        // iterate over received objects and store data
        [self.managedObjectContext lock];
        for(NSDictionary* json in resultList){
            // insert object into context
            [NSManagedObject objectForEntityForName:entity 
                             inManagedObjectContext:self.managedObjectContext 
                                           fromJSON:json];
        }
        [self.managedObjectContext unlock];
    }
    // no errors detected
    return YES;
}

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
                       error:(NSError**)error {
    if (error) {
        *error = nil;
    }
    
    NSError* remoteError = nil;
    // get all entities from remote endpoint
    //
    remoteError = nil;
    NSArray* resultList = [self remote:@"GET" path:URI data:nil error:&remoteError];
    if (!resultList) {
        if (error) {
            *error = remoteError;
        }
        return NO;
    }
    
    // Store entities localy
    //
    if(resultList.count > 0){
        // iterate over received objects and store data
        [self.managedObjectContext lock];
        for(NSDictionary* json in resultList){
            // insert object into context
            [NSManagedObject objectForEntityForName:entity 
                             inManagedObjectContext:self.managedObjectContext 
                                           fromJSON:json];
        }
        [self.managedObjectContext unlock];
    }
    // no errors detected
    return YES;
}

@end
