//
//  WeeDetailViewController.m
//  weDaily
//
//  Created by luanjunyi on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeeDetailViewController.h"
#import "Wee.h"

@implementation WeeDetailViewController
@synthesize webView, wee;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.wee.href]];
    [self.webView loadRequest:request];
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = 
    [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
    
    // Set to Left or Right
    [[self navigationItem] setRightBarButtonItem:barButton];
    [loadingIndicator startAnimating];
}


- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Failed" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    NSLog(@"loading wee detail page failed:%@", error.description);
}

@end
