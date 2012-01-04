//
//  PicfulImage.m
//  picful
//
//  Created by luanjunyi on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicfulImage.h"
#import "SBJson.h"

@implementation PicfulImage

@synthesize DBid, image;

-(id) initWithData:(NSData *)data {
    self = [self init];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json string:%@", [json_string substringToIndex:40]);

    NSError *error;
    NSDictionary *json = [parser objectWithString:json_string error:&error];
    if (json == nil) {
        NSLog(@"failed to parse json:%@", error.description);
        return nil;
    }
    
    NSURL *imageBase64URL = [NSURL URLWithString:[NSString stringWithFormat:@"data:image/jpg;base64,%@", [json objectForKey:@"image_base64"]]];
    NSData *imageBin = [NSData dataWithContentsOfURL:imageBase64URL];
    self.image = [UIImage imageWithData:imageBin];
    
    self.DBid = [(NSString *)[json objectForKey:@"picture_id"] intValue];

    NSLog(@"image id:%d", self.DBid);
    return self;
}

@end
