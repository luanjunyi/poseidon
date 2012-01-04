//
//  WeeDetailViewController.h
//  weDaily
//
//  Created by luanjunyi on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wee.h"

@interface WeeDetailViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Wee *wee;


@end
