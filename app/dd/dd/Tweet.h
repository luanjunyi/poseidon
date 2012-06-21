//
//  Tweet.h
//  dd
//
//  Created by luanjunyi on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tweet;

@protocol TweetDelegate <NSObject>
@required
-(void) imageJustDownloadedFor:(Tweet *)tweet;

@end

@interface Tweet : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) NSUInteger createdEpoch;
@property (nonatomic, assign) id <TweetDelegate> delegate;					

-(id) initWithTitle:(NSString *)theTitle content:(NSString *)theContent image:(UIImage *)theImage imageURL:(NSString *)theImageURL createdAt:(NSUInteger)epoch;
-(void) downloadImage;

@end
