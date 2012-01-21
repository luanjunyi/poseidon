//
//  BCMFilterRule.m
//  BCMSServices
//
//  Created by proxi on 11-12-22.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

#import "BCMFilterRule.h"

NSCompoundPredicateType NSCompoundPredicateTypeFromBCMFilterRule(BCMFilterRule rule) {
    switch (rule) {
        case BCMFilterRuleAND:
            return NSAndPredicateType;
        case BCMFilterRuleOR:
            return NSOrPredicateType;
        default:
            return NSNotPredicateType;
    }
}
