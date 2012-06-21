//
//  ViewController.h
//  dd
//
//  Created by luanjunyi on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

const CGFloat CELL_WIDTH = 320.0f;
const CGFloat CELL_MARGIN = 10.0f;
const CGFloat IMAGE_HEIGHT = 196.0f;

@interface RootViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSUInteger curCellLineNum;
}

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, weak) EGORefreshTableHeaderView *refreshHeader;
@property(nonatomic, assign) NSUInteger rowCount;

@property(nonatomic, strong) NSMutableArray *cellTexts;
@property(nonatomic, strong) NSMutableArray *cellImages;

@end
