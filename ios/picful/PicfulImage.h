//
//  PicfulImage.h
//  picful
//
//  Created by luanjunyi on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicfulImage : NSObject

@property(nonatomic, assign) NSInteger DBid;
@property(nonatomic, strong) UIImage *image;

-(id) initWithData:(NSData *)data;

@end
