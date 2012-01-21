//
//  BCMIncidentStatus.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncident;

@interface BCMIncidentStatus : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *inverseIncidents;
@end

@interface BCMIncidentStatus (CoreDataGeneratedAccessors)

- (void)addInverseIncidentsObject:(BCMIncident *)value;
- (void)removeInverseIncidentsObject:(BCMIncident *)value;
- (void)addInverseIncidents:(NSSet *)values;
- (void)removeInverseIncidents:(NSSet *)values;
@end
