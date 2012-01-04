//
//  WeeTableViewController.m
//  weDaily
//
//  Created by luanjunyi on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeeTableViewController.h"
#import "WeeCell.h"
#import "WeeDetailViewController.h"
#import "QuartzCore/QuartzCore.h"


@implementation WeeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Wee";
    
    WeeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.abstract.text = @"Bertie and Bean希望打造一个家长们可承受、方便的童装交易平台。家长在最初注册时即会获得两个环保童装“包”，然后可以用这两个包将需要交换的童装打包起来，并在网上填写详细的信息。如果有人选中了这个包，选择人会支付15英镑，然后系统便通知对方发货。几天之后，选中人就会收到他选中的包裹。其中选中人支付的15英镑并非服装价值，而是包括物流、快递费、慈善捐款（1英镑）和Bertie and Bean的提成，至于服装——它们是免费的。Bertie and Bean希望打造一个家长们可承受、方便的童装交易平台。家长在最初注册时即会获得两个环保童装“包”，然后可以用这两个包将需要交换的童装打包起来，并在网上填写详细的信息。如果有人选中了这个包，选择人会支付15英镑，然后系统便通知对方发货。几天之后，选中人就会收到他选中的包裹。其中选中人支付的15英镑并非服装价值，而是包括物流、快递费、慈善捐款（1英镑）和Bertie and Bean的提成，至于服装——它们是免费的。Bertie and Bean希望打造一个家长们可承受、方便的童装交易平台。家长在最初注册时即会获得两个环保童装“包”，然后可以用这两个包将需要交换的童装打包起来，并在网上填写详细的信息。如果有人选中了这个包，选择人会支付15英镑，然后系统便通知对方发货。几天之后，选中人就会收到他选中的包裹。其中选中人支付的15英镑并非服装价值，而是包括物流、快递费、慈善捐款（1英镑）和Bertie and Bean的提成，至于服装——它们是免费的。Bertie and Bean希望打造一个家长们可承受、方便的童装交易平台。家长在最初注册时即会获得两个环保童装“包”，然后可以用这两个包将需要交换的童装打包起来，并在网上填写详细的信息。如果有人选中了这个包，选择人会支付15英镑，然后系统便通知对方发货。几天之后，选中人就会收到他选中的包裹。其中选中人支付的15英镑并非服装价值，而是包括物流、快递费、慈善捐款（1英镑）和Bertie and Bean的提成，至于服装——它们是免费的。";
    
    cell.layer.cornerRadius = 20.0f;
    cell.clipsToBounds = YES;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //[self performSegueWithIdentifier:<#(NSString *)#> sender:<#(id)#>
    NSLog(@"selected");
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushWeeDetail"]) {
        WeeDetailViewController *detail = (WeeDetailViewController *)segue.destinationViewController;
        detail.hidesBottomBarWhenPushed = YES;
        detail.wee = [[Wee alloc] init];
        detail.wee.href = @"http://www.36kr.com/p/73603.html";
    }
}

@end
