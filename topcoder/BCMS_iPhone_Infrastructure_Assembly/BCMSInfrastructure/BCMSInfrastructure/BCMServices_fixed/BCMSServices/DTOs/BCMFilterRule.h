//
//  BCMFilterRule.h
//  BCMSServices
//
//  Created by proxi on 11-12-12.
//  Copyright (c) 2011 TopCoder. All rights reserved.
//

/**
 * Filter rule enumeration.
 * @author proxi
 * @version 1.0
 */
typedef enum {
    /**
     * AND filter rule.
     */
    BCMFilterRuleAND,
    /**
     * OR filter rule.
     */
    BCMFilterRuleOR
} BCMFilterRule;

/**
 * Gets <code>NSCompoundPredicateType</code> corresponding to given <code>BCMFilterRule</code>.
 * @param rule Rule to convert.
 * @return Matching <code>NSCompoundPredicateType</code>.
 */
NSCompoundPredicateType NSCompoundPredicateTypeFromBCMFilterRule(BCMFilterRule rule);
