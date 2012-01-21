//
//  BCMIncidentAssociation.h
//  BCMSServices
//
//  Created by proxi on 11-12-13.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BCMIncident;

@interface BCMIncidentAssociation : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) BCMIncident *primaryIncidentReport;
@property (nonatomic, retain) NSSet *secondaryIncidentReports;
@end

@interface BCMIncidentAssociation (CoreDataGeneratedAccessors)

- (void)addSecondaryIncidentReportsObject:(BCMIncident *)value;
- (void)removeSecondaryIncidentReportsObject:(BCMIncident *)value;
- (void)addSecondaryIncidentReports:(NSSet *)values;
- (void)removeSecondaryIncidentReports:(NSSet *)values;
@end
