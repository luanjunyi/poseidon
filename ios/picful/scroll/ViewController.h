//
//  ViewController.h
//  scroll
//
//  Created by luanjunyi on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"

@interface UIView(IWantToGetRejected)

+ (void) setAnimationPosition:(CGPoint)p ;

@end

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, ImageLoaderDelegate> {
    UIImage *heartImage;
    UIImage *junkImage;
    UIImageView *staticSymbol;
    UIImageView *dynamicSymble;
    NSString *ratingStat;
}


@property (weak, atomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *curtainView;
@property (strong, nonatomic) UIAlertView *waitingAlert;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecgonizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (strong, nonatomic) ImageLoader *imageLoader;


- (IBAction)tapped:(UITapGestureRecognizer *)sender;
- (IBAction)twoTapDetected:(id)sender;
- (IBAction)panDetected:(UIPanGestureRecognizer *)sender;
- (IBAction)swipeLeft:(id)sender;

- (void) heartImage;
- (void) junkImage;

- (void) tryUpdateMainImage;
- (void) endWaitLoading;
- (void) startWaitLoading;




@end
