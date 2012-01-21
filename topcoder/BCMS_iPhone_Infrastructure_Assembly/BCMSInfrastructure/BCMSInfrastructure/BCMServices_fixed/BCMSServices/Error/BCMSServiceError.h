//
//  BCMSServiceError.h
//  BCMSServices
//
//  Created by proxi on 11-12-22.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

/**
 * Error domain for errors reported by services library.
 */
extern NSString* const BCMSServiceErrorDomain;

enum {
    /**
     * Error originating in remote service.
     */
    kBCMSServiceRemoteError = 0
};
