//
//  Tweet.m
//  dd
//
//  Created by luanjunyi on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "ASIHTTPRequest.h"

@implementation Tweet

@synthesize title, content, image, imageURL, createdEpoch, delegate;

#pragma mark NSCoding Protocal

-(void) encodeWithCoder:(NSCoder *)coder {
    NSAssert1([coder allowsKeyedCoding],
              @"%@ does not support sequential archiving.",
              [[coder class] description]);
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.imageURL forKey:@"imageURL"];
}

-(id) initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.title = [decoder decodeObjectForKey:@"title"];
    self.content = [decoder decodeObjectForKey:@"content"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
    
    if ([self.title isEqual:[NSNull null]])
        self.title = @"Untitled";
    if ([self.content isEqual:[NSNull null]])
        self.content = @"";
    return self;
}

-(id) initWithTitle:(NSString *)theTitle content:(NSString *)theContent image:(UIImage *)theImage imageURL:(NSString *)theImageURL createdAt:(NSUInteger)epoch{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.title = theTitle;
    self.content = theContent;
    self.image = theImage;
    self.imageURL = theImageURL;
    self.createdEpoch = epoch;
    
    if ([self.title isEqual:[NSNull null]])
        self.title = @"Untitled";
    if ([self.content isEqual:[NSNull null]])
        self.content = @"";

    return self;
}

-(void) downloadImage {
    if ([self.imageURL isEqualToString:@""])
        return;
    NSURL *url = [NSURL URLWithString:self.imageURL];
    NSLog(@"downloading image from:%@", url);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.timeOutSeconds = 60;
    [request startSynchronous];
}

#pragma mark - ASIHTTPRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    self.image = [[UIImage alloc] initWithData:responseData];
    [self.delegate imageJustDownloadedFor:self];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"response failed: %@", error.description);
}

@end
