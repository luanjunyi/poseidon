//
//  RootViewController.m
//
//  Created by luanjunyi on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "TableCell.h"


@implementation RootViewController

@synthesize isLoading, refreshHeader;
@synthesize tweets;
@synthesize curveMenu;

#pragma mark - local helper functions

- (void) loadCurveMenu {
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    QuadCurveMenuItem *starMenuItem1 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem2 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem3 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem4 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem5 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];

    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, nil];
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];
    

    

    // customize menu
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    //NSLog(@"screen height: %.2f", screenHeight);
    menu.center = CGPointMake(25, screenHeight - 55);
    menu.rotateAngle = 0;
    menu.menuWholeAngle = M_PI / 1.6f;
    menu.farRadius = 150.0f;
    menu.endRadius = 140.0f;
    menu.nearRadius = 130.0f;
    menu.timeOffset = 0.006f;
    self.curveMenu = menu;
    [self.tableView addSubview:self.curveMenu];
}

- (void) addNewTweetInJson:(NSArray *)jsonArray {
    for (NSDictionary *json in jsonArray) {
        Tweet *tweet = [[Tweet alloc] initWithTitle:[json objectForKey:@"title"]
                                            content:[json objectForKey:@"content"]
                                              image:nil
                                           imageURL:[json objectForKey:@"image_url"]
                                          createdAt:[[json objectForKey:@"date"] integerValue]];
        tweet.delegate = self;
        [tweet downloadImage];
        [self.tweets addObject:tweet];
    }
    NSLog(@"%d tweets all together", self.tweets.count);
}

#pragma mark - View controller routines

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buryToFile) name:UIApplicationWillResignActiveNotification object:nil];
    
    if (self.refreshHeader == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		self.refreshHeader = view;
	}
    
    if (self.tweets == nil) {
        self.tweets = [NSMutableArray arrayWithCapacity:10];
    }
    
	//  update the last update date
	[self.refreshHeader refreshLastUpdatedDate];
    
    if (self.curveMenu == nil) {
        [self loadCurveMenu];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.curveMenu = nil;
    self.tweets = nil;
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self recoverFromFile];
    //[self reloadTableViewDataSource];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self buryToFile];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return YES;
    }
}

- (NSString *)epochFilePath {
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [myPathList objectAtIndex:0];
    NSString *path = [dirPath stringByAppendingPathComponent:@"LastPull"];
    return path;
}

- (NSString *)tweetsFilePath {
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [myPathList objectAtIndex:0];
    NSString *path = [dirPath stringByAppendingPathComponent:@"Tweets"];
    return path;
}

- (void) recoverFromFile {
    NSString *path = [self epochFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        [[file readDataOfLength:sizeof(self->lastPullEpoch)] getBytes:&self->lastPullEpoch]; 
        NSData *data = [NSData dataWithContentsOfFile:path];
        self->lastPullEpoch = *(NSUInteger *)[data bytes];
    } else {
        self->lastPullEpoch = 0;
    }

    NSLog(@"last pull epoch: %u", self->lastPullEpoch);
    
    path = [self tweetsFilePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.tweets = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        NSLog(@"recovered tweets from %@", path);
    } else {
        NSLog(@"tweets path(%@) doesn't exist", path);
    }
    
}

- (void) buryToFile {
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [myPathList objectAtIndex:0];
    NSString *path = [dirPath stringByAppendingPathComponent:@"LastPull"];
    NSData *data = [NSData dataWithBytes:&self->lastPullEpoch length:sizeof(self->lastPullEpoch)];
    [data writeToFile:path atomically:YES];
    
    path = [dirPath stringByAppendingPathComponent:@"Tweets"];
    [NSKeyedArchiver archiveRootObject:self.tweets toFile:path];
    
    
    NSLog(@"data buried to file");
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //TableCell *cell = (TableCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (TableCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	// Configure the cell.
    NSUInteger index = self.tweets.count - indexPath.row - 1;
    Tweet *tweet = (Tweet *)[self.tweets objectAtIndex:index];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:tweet.createdEpoch];
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    NSInteger month = dateComp.month;
    NSInteger dayOfMonth = dateComp.day;
    //NSLog(@"tweet created at:%d/%d/%d", dateComp.year, month, dayOfMonth);
    UIImage *image = nil;
    if (tweet.image == nil) {
        [tweet downloadImage];
        image = [UIImage imageNamed:@"sample.jpg"];
    } else {
        image = tweet.image;
    }
    //NSLog(@"content:(%@), is null?%d", tweet.content, tweet.content == [NSNull null]);
    NSUInteger truncatedLength = MIN(144, [tweet.content length]);
    NSString *text = [tweet.content substringToIndex:truncatedLength];
    text = [text stringByReplacingOccurrencesOfString:@"\\s"
                                           withString:@" "
                                              options:NSRegularExpressionSearch
                                                range:NSMakeRange(0, [text length])];
    
    text = [NSString stringWithFormat:@"'%@'", text];

    // Date and month
    cell.dayLabel.text = [NSString stringWithFormat:@"%02d", dayOfMonth];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    cell.monthLabel.text = [df.shortMonthSymbols objectAtIndex:month-1];
    
    // Content
    cell.text.text = text;
    CGRect frame = cell.text.frame;
    

    
    frame.size.height = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CELL_WIDTH, 20000.0f)].height;
    cell.text.frame = frame;
    NSLog(@"real height for row %d:%.2f, width:%.2f", indexPath.row, frame.size.height, frame.size.width);
    
    // Image
    CGRect textFrame = cell.text.frame;
    cell.image.image = image;
    cell.image.frame = CGRectMake(textFrame.origin.x, textFrame.origin.y + textFrame.size.height + CELL_MARGIN, CELL_WIDTH, IMAGE_HEIGHT);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = Nil;
    CGSize size;
    @try {
        NSUInteger index = self.tweets.count - indexPath.row - 1;
        Tweet *tweet = (Tweet *)[self.tweets objectAtIndex:index];
        text = [tweet.content substringToIndex:144];

        text = [text stringByReplacingOccurrencesOfString:@"\\s"
                                               withString:@" "
                                                  options:NSRegularExpressionSearch
                                                    range:NSMakeRange(0, [text length])];
        text = [NSString stringWithFormat:@"'%@'", text];
        
        size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CELL_WIDTH, 20000.0f)];
    }
    @catch (NSException *exception) {
        NSLog(@"tweet failed:(%@)", text);
    }
    @finally {
        NSLog(@"predicted height for row %d:%.2f", indexPath.row, size.height);
        return size.height + IMAGE_HEIGHT + CELL_BLANK + CELL_MARGIN;
    }
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    //NSLog(@"response: %@", response);
    [self doneLoadingTableViewData:response];
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"response failed: %@", error.description);
    [self doneLoadingTableViewData:nil];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	self.isLoading = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%d", PULL_URL, self->lastPullEpoch]];
    NSLog(@"Pulling from %@", [url absoluteString]);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    request.delegate = self;
    [request startAsynchronous];
	
}

- (void)doneLoadingTableViewData:(NSString *)data{
	//  model should call this when its done loading
	self.isLoading = NO;
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    if (data != nil) {
        NSArray *json = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSLog(@"%d posts pulled", json.count);
        [self addNewTweetInJson:json];
        self->lastPullEpoch = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
        NSLog(@"last pull time updated to: %u", self->lastPullEpoch);
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat originalY = screenHeight - 55;
    CGPoint pos = self.curveMenu.center;
    self.curveMenu.center = CGPointMake(pos.x, originalY + scrollView.contentOffset.y);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return self.isLoading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark -
#pragma mark TweetDelegate
- (void) imageJustDownloadedFor:(Tweet *)tweet {
    [self.tableView reloadData];
}


@end
