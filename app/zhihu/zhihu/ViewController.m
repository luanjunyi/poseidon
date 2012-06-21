//
//  ViewController.m
//  zhihu
//
//  Created by luanjunyi on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize webView;
@synthesize loadingCurtain;
@synthesize upButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Load zhihu home page
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://zhidao.baidu.com"]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setLoadingCurtain:nil];
    [self setUpButton:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setRefreshButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

// UIWebViewDelegate
- (void) webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webview loading start");
    self.loadingCurtain.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(webViewDidFinishLoad:) userInfo:nil repeats:NO];
    self.backButton.hidden = !self.webView.canGoBack;
    self.forwardButton.hidden = !self.webView.canGoForward;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webview loading finished");
    self.loadingCurtain.hidden = YES;
    self.backButton.hidden = !self.webView.canGoBack;
    self.forwardButton.hidden = !self.webView.canGoForward;
    //[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
}

// UIGestureRecognizer

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"tapped");
    return;
    BOOL hiddend = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:!hiddend withAnimation:UIStatusBarAnimationSlide];
    self.backButton.hidden = !hiddend || !self.webView.canGoBack;
    self.forwardButton.hidden = !hiddend || !self.webView.canGoForward;
    //self.refreshButton.hidden = !hiddend;

}

- (IBAction)upArrowTouched:(id)sender {
    self.webView.scrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)goBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward];
}
@end
