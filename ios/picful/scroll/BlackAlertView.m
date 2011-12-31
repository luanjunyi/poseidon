//
//  BlackAlertView.m
//  picful
//
//  Created by luanjunyi on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BlackAlertView.h"
#import <QuartzCore/CAAnimation.h>

@implementation BlackAlertView

-(id) initWithMessage:(NSString *)message {
    self.layer.cornerRadius = 10.0f;
    return self;
}

@end
