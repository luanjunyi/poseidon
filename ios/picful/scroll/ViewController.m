//
//  ViewController.m
//  scroll
//
//  Created by luanjunyi on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BlackAlertView.h"
#import <QuartzCore/CAAnimation.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation ViewController


@synthesize panRecgonizer;
@synthesize singleTapRecognizer;
@synthesize imageView;
@synthesize curtainView, launchView, ratingStat;
@synthesize leftSwipeRecognizer;
@synthesize waitingAlert, imageLoader;


#pragma mark - Curtain related utils

CGFloat kCurtainScrollThreshold = 90.0f;
CGFloat kCurtainAlphaMax = 0.85f;

- (void) disableUI {
    self.panRecgonizer.enabled = NO;
    self.leftSwipeRecognizer.enabled = NO;
    NSLog(@"UI disabled");
}

- (void) enableUI {
    self.panRecgonizer.enabled = YES;
    self.leftSwipeRecognizer.enabled = YES;
    NSLog(@"UI enabled");
}

- (void) prepareCurtainForType:(NSString *)stat {
    if (stat == @"heart") {
        ratingStat = @"heart";
        staticSymbol.image = dynamicSymble.image = heartImage;
        dynamicSymble.center = CGPointMake(self.curtainView.center.x, self.view.frame.size.height + dynamicSymble.frame.size.height / 2.0f);
    } else if (stat == @"junk") {
        ratingStat = @"junk";
        staticSymbol.image = dynamicSymble.image = junkImage;
        dynamicSymble.center = CGPointMake(self.curtainView.center.x, -dynamicSymble.frame.size.height / 2.0f);
    } else {
        NSLog(@"unrecognized curtain type: %@", stat);
    }
    
    staticSymbol.center = self.curtainView.center;
    
    self.curtainView.hidden = NO;
    [self.curtainView addSubview:staticSymbol];
    [self.curtainView addSubview:dynamicSymble];
}

- (void) resetCurtain {
    [UIView animateWithDuration:0.4f animations:^{
        self.curtainView.alpha = 0.0f;
        if ([ratingStat isEqualToString:@"heart"]) {  // Showing 'heart'
            dynamicSymble.center = CGPointMake(self.curtainView.center.x, self.view.frame.size.height + dynamicSymble.frame.size.height / 2.0f);
        } else { // Showing 'junk'
            dynamicSymble.center = CGPointMake(self.curtainView.center.x, -dynamicSymble.frame.size.height / 2.0f);           
        }
    } completion:^(BOOL finished) {
        self.curtainView.hidden = YES;
        for (UIView* subview in [self.curtainView subviews]) {
            [subview removeFromSuperview];
        }
    }];
}

- (void) resetCurtainWithouthMovement {
    [UIView animateWithDuration:0.4f animations:^{
        self.curtainView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.curtainView.hidden = YES;
        if (dynamicSymble.center.y > self.curtainView.center.y) {  // Showing 'heart'
            dynamicSymble.center = CGPointMake(self.curtainView.center.x, self.view.frame.size.height + dynamicSymble.frame.size.height / 2.0f);
        } else { // Showing 'junk'
            dynamicSymble.center = CGPointMake(self.curtainView.center.x, -dynamicSymble.frame.size.height / 2.0f);           
        }
        for (UIView* subview in [self.curtainView subviews]) {
            [subview removeFromSuperview];
        }
    }];
}

- (void) handlePanDown:(CGFloat)offset {
    offset = ABS(offset);
    
    if (self.curtainView.hidden == YES) {
        [self prepareCurtainForType:@"heart"];
    }
    
    CGFloat cur = offset / kCurtainScrollThreshold;
    if (cur >= 0.999999999999) {
        cur = 1.0;
    }

    self.curtainView.alpha = kCurtainAlphaMax * cur;
    CGFloat totalMoveLength = (self.view.frame.size.height + dynamicSymble.frame.size.height) / 2.0;
    dynamicSymble.center = CGPointMake(dynamicSymble.center.x, self.curtainView.center.y + (1 - cur) * totalMoveLength);
    
    if (cur == 1.0) {
        [self heartImage];
    }
}

- (void) handlePanUp:(CGFloat)offset {
    offset = ABS(offset);
    
    if (self.curtainView.hidden == YES) {
        [self prepareCurtainForType:@"junk"];
    }
    
    CGFloat cur = offset / kCurtainScrollThreshold;
    if (cur >= 0.9999999999999) {
        cur = 1.0;
    }

    self.curtainView.alpha = kCurtainAlphaMax * cur;
    CGFloat totalMoveLength = (self.view.frame.size.height + dynamicSymble.frame.size.height) / 2.0;
    dynamicSymble.center = CGPointMake(dynamicSymble.center.x, self.curtainView.center.y - (1 - cur) * totalMoveLength);
    if (cur == 1.0) {
        [self junkImage];
    }
}

- (void) updateMainImage:(UIImage *)image {

    if (image == nil) {
        return;
    }

    self.imageView.image = image;

    @try {

        if ([ratingStat isEqualToString:@"heart"]) {  // Showing 'heart'
            [UIView animateWithDuration:1.0 animations:^{
                CATransition* animation = [CATransition animation];
                animation.type = @"rippleEffect";
                animation.duration = 0.5;
                [self.imageView.layer addAnimation:animation forKey:@"anim.heart"];
                
            } completion:^(BOOL finished) {
                [self enableUI];
                [self endWaitLoading];
                [self resetCurtainWithouthMovement];
                ratingStat = @"";
            }];            
            

        } else if ([ratingStat isEqualToString:@"junk"]) { // Showing 'junk'
            [UIView animateWithDuration:1.0 animations:^{
                CATransition* animation = [CATransition animation];
                animation.type = @"rippleEffect";
                animation.duration = 0.5;
                [self.imageView.layer addAnimation:animation forKey:@"anim.heart"];
                
            } completion:^(BOOL finished) {
                [self enableUI];
                [self endWaitLoading]; 
                [self resetCurtainWithouthMovement];
                ratingStat = @"";
            }];  
            
//            [UIView beginAnimations:@"suck" context:NULL];
//            [UIView setAnimationDuration:1.0];
//            [UIView setAnimationTransition:1 forView:self.imageView cache:YES];
//            [UIView setAnimationPosition:self.view.center];
//            [UIView commitAnimations];
//            
//            self.imageView.image = image;
//            [self enableUI];
//            [self endWaitLoading];
//            ratingStat = @"";


        } else if ([ratingStat isEqualToString:@"swipe"]) {
            [UIView animateWithDuration:1.0 animations:^{
                CATransition* animation = [CATransition animation];
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromRight;
                animation.duration = 0.5;
                [self.imageView.layer addAnimation:animation forKey:@"anim.heart"];
                
            } completion:^(BOOL finished) {
                [self enableUI];
                [self endWaitLoading]; 
                [self resetCurtainWithouthMovement];
                ratingStat = @"";
            }];            
        } else if ([ratingStat isEqualToString:@"launching"]) {
            [UIView animateWithDuration:1.0 animations:^{
                self.launchView.alpha = 0;
            } completion:^(BOOL finished) {
                ratingStat = @"";
                [self enableUI];
                self.launchView.hidden = YES;
            }];

        } else {
            NSLog(@"rating stat is %@, error?", ratingStat);
        }
        

    } @catch (NSException *error) {
        NSLog(@"Sucking exception: %@", error);
        NSLog(@"%@",[NSThread callStackSymbols]);
    }
}

- (void) tryUpdateMainImage {
    UIImage *img = [imageLoader getNextImage];
    if (img != nil) {
        [self updateMainImage:img];
    } else {
        [self startWaitLoading];
    }
}

#pragma mark - Rating image

- (void) startWaitLoading {
    if (self.launchView.hidden == NO) {
        return;
    }
    
    NSString *message = NSLocalizedString(@"Downloading Pictures\nPlease Wait...", @"downloading, please wait");
    waitingAlert = [waitingAlert initWithMessage:message];
    waitingAlert.center = self.view.center;
    waitingAlert.hidden = NO;
    [self disableUI];
}

- (void) endWaitLoading {
    if (waitingAlert != nil) {
        waitingAlert.hidden = YES;
    }
    self.launchView.hidden = YES;
    [self enableUI];
}

- (void) heartImage {
    [self disableUI];
    // Send hearting info to server
    
    // Get next image
    [self performSelector:@selector(tryUpdateMainImage) withObject:nil afterDelay:0.2f];
    //[self tryUpdateMainImage];
}

- (void) junkImage {
    [self disableUI];
    // Send junking info to server 

    // Get next image
    [self performSelector:@selector(tryUpdateMainImage) withObject:nil afterDelay:0.2f];
    //[self tryUpdateMainImage];
}

#pragma ImageLoader delegate

-(void) newPictureDidArrive:(ImageLoader *)loader {
    if (waitingAlert.hidden && launchView.hidden) {
        return;
    }
    UIImage *img = [imageLoader getNextImage];
    if (img != nil) {
        [self performSelectorOnMainThread:@selector(updateMainImage:)withObject:img waitUntilDone:YES]; 

    }
}


#pragma mark - Utils

- (void) showSplashScreen {
    launchView = [[UIView alloc] initWithFrame:self.view.frame];
    launchView.backgroundColor = [UIColor blackColor];
    
    int rowNum = 6;
    int colNum = 4;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        colNum = 6;
        rowNum = 4;
    }
    NSLog(@"orientation: %d", self.interfaceOrientation);
    [self disableUI];  // Protect the splash screen from random gestures
    for (int i = 0; i < rowNum; i++) {
        
        for (int j = 0; j < colNum; j++) {
            int imageId = i * 4 + j;
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", imageId + 1]];
            UIImageView *curImageView = [[UIImageView alloc] initWithImage:image];
            curImageView.frame = CGRectMake(j * 80, i * 80, 80, 80);
            curImageView.alpha = 0;
            [launchView addSubview:curImageView];
            CGFloat delay = (arc4random() % 100000) / 100000.0 * 3.0;
            [UIView animateWithDuration:1 delay:delay options: UIViewAnimationOptionTransitionNone animations:^{
                curImageView.alpha = 1.0;
            } completion:nil];
        }
    }
    
    [self.view addSubview:launchView];
    self.launchView = launchView;
    self.ratingStat = @"launching";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"ViewController viewDidLoad");
	// Do any additional setup after loading the view, typically from a nib.
    if (heartImage == nil) {
        heartImage = [UIImage imageNamed:@"heart-red.png"];
    }
    if (junkImage == nil) {
        junkImage = [UIImage imageNamed:@"junk-black.png"];  
    }
    
    [self showSplashScreen];
    
    staticSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.3)];
    dynamicSymble = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.3)];
    staticSymbol.contentMode = dynamicSymble.contentMode = UIViewContentModeScaleAspectFit;
    staticSymbol.autoresizingMask = dynamicSymble.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.panRecgonizer requireGestureRecognizerToFail:self.leftSwipeRecognizer];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLeftSwipeRecognizer:nil];
    [self setSingleTapRecognizer:nil];
    [self setCurtainView:nil];
    [self setWaitingAlert:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.launchView.center = self.view.center;
        self.launchView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        launchView.transform =  CGAffineTransformMakeRotation(M_PI / 2.0);
    }
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Event Handler
   

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    NSLog(@"Swipe Left");
    ratingStat = @"swipe";
    [self tryUpdateMainImage];
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");

}

- (IBAction)twoTapDetected:(id)sender {
    NSLog(@"Double Tapped");
    
    if (self.imageView.contentMode == UIViewContentModeScaleToFill) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    } else if (self.imageView.contentMode == UIViewContentModeScaleAspectFit) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
}


- (IBAction)panDetected:(UIPanGestureRecognizer *)sender {
    //NSLog(@"Pan Detected");
    if (!panRecgonizer.enabled) {
        return;
    }
    
    CGPoint translate = [sender translationInView:self.view];
    
    CGFloat offset = translate.y;
    //NSLog(@"pan: %.2f", offset);
    
    if (offset == 0) {
        [self resetCurtain];
    } else if (offset > 0) { // Pulling down
        [self handlePanDown:offset];
    } else {
        [self handlePanUp:offset];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded && ABS(offset) < kCurtainScrollThreshold) {
        [self resetCurtain];
    }
}

@end
