//
//  RootViewController.m
//
//  Created by luanjunyi on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "TableCell.h"


@implementation RootViewController

@synthesize isLoading, refreshHeader, rowCount;
@synthesize cellTexts, cellImages;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.rowCount = 0;
    if (self.refreshHeader == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		self.refreshHeader = view;
	}
	
    if (self.cellTexts == nil) {
        self.cellTexts = [NSMutableArray arrayWithCapacity:10];
    }
    if (self.cellImages == nil) {
        self.cellImages = [NSMutableArray arrayWithCapacity:10];
    }
	//  update the last update date
	[self.refreshHeader refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return YES;
    }
}

- (void) addCellTextForRow:(NSUInteger) rowIndex {
    int lineNum = arc4random() % 4 + 1;
    
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"Cell %d with line %d", rowIndex + 1, lineNum];
    for (int i = 0; i < lineNum; i++) {
        [content appendFormat:@"\nline %d", i + 1];
    }
    [self.cellTexts addObject:content];
}

- (void) addCellImageForRow:(NSUInteger) rowIndex {
    [self.cellImages addObject:[UIImage imageNamed:@"sample.jpg"]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (TableCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	// Configure the cell.
    NSUInteger index = self.rowCount - indexPath.row - 1;
    
    cell.text.frame = CGRectMake(0, 10, CELL_WIDTH, 20000);
    cell.text.text = (NSString *)[self.cellTexts objectAtIndex:index];
    CGRect frame = cell.text.frame;
    frame.size.height = cell.text.contentSize.height;
    cell.text.frame = frame;
    CGRect textFrame = cell.text.frame;
    cell.image.image = (UIImage *)[self.cellImages objectAtIndex:index];
    cell.image.frame = CGRectMake(textFrame.origin.x, textFrame.origin.y + textFrame.size.height + CELL_MARGIN, CELL_WIDTH, IMAGE_HEIGHT);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = self.rowCount - indexPath.row - 1;
    NSString *text = (NSString *)[self.cellTexts objectAtIndex:index];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CELL_WIDTH, 20000.0f)];
    
    return size.height + IMAGE_HEIGHT + CELL_MARGIN * 6;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	self.isLoading = YES;
    self.rowCount++;
    [self addCellTextForRow:self.rowCount - 1];
    [self addCellImageForRow:self.rowCount - 1];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
	
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	self.isLoading = NO;
	[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
    
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


@end
