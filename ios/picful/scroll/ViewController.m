//
//  ViewController.m
//  scroll
//
//  Created by luanjunyi on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation ViewController

@synthesize panRecgonizer;
@synthesize singleTapRecognizer;
@synthesize imageView;
@synthesize curtainView;
@synthesize leftSwipeRecognizer;

@synthesize waitingAlert, imageLoader;


#pragma mark - Curtain related utils

CGFloat kCurtainScrollThreshold = 90.0f;
CGFloat kCurtainAlphaMax = 0.85f;

- (void) disableUI {
    self.panRecgonizer.enabled = NO;
    NSLog(@"UI disabled");
}

- (void) enableUI {
    self.panRecgonizer.enabled = YES;
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
    waitingAlert = [[UIAlertView alloc] initWithTitle:@"Downloading Pictures\nPlease Wait..." message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [waitingAlert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(waitingAlert.bounds.size.width / 2, waitingAlert.bounds.size.height - 50);
    [indicator startAnimating];
    [waitingAlert addSubview:indicator];
    [indicator startAnimating];
}

- (void) endWaitLoading {
    [waitingAlert dismissWithClickedButtonIndex:0 animated:YES];
    waitingAlert = nil;
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
    if (waitingAlert == nil) {
        return;
    }
    
    UIImage *img = [imageLoader getNextImage];
    if (img != nil) {
        [self performSelectorOnMainThread:@selector(updateMainImage:)withObject:img waitUntilDone:YES]; 

    }
}


#pragma mark - Utils


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

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Event Handler
   

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
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
