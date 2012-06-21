//
//  ViewController.h
//  dd
//
//  Created by luanjunyi on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "QuadCurveMenu.h"
#import "Tweet.h"

#define PULL_URL "http://var.grampro.com/pull/?type=duidiu_daidai&since="

const CGFloat CELL_WIDTH = 260.0f;
const CGFloat CELL_MARGIN = 10.0f;
const CGFloat IMAGE_HEIGHT = 189.0f;
const CGFloat CELL_BLANK = 10.0f;


@interface RootViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, TweetDelegate> {
    NSUInteger curCellLineNum;
    NSUInteger lastPullEpoch;
}

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, weak) EGORefreshTableHeaderView *refreshHeader;
@property(nonatomic, strong) QuadCurveMenu *curveMenu;

@property(nonatomic, strong) NSMutableArray *tweets;

- (void) recoverFromFile;
- (void) buryToFile;
- (void) imageJustDownloadedFor:(Tweet *)tweet;

@end
