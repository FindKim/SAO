//
//  SAOClubTableViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/15/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOClubTableViewController.h"
#import "SAOClubNavigationController.h"
#import "CSVParser.h"
#import "SAOTabBarController.h"

@interface SAOClubTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray * searchResults;
@property (nonatomic) BOOL hasDataEverLoaded; // YES if data has loaded once, will not load again until refreshed

@end

@implementation SAOClubTableViewController

- (void) receiveCategoryNotification:(NSNotification *) notification
{

    NSLog (@"Successfully received the category notification!");
    NSLog(@"The notification is %@", notification);
    int section = 0;
    if ([[notification name] isEqualToString:@"Academic"]) {
        section = 0;
    } else if ([[notification name] isEqualToString:@"Athletic"]) {
        section = 1;
    } else if ([[notification name] isEqualToString:@"Cultural"]) {
        section = 2;
    } else if ([[notification name] isEqualToString:@"Performing Arts"]) {
        section = 3;
    } else if ([[notification name] isEqualToString:@"Social Service"]) {
        section = 4;
    } else if ([[notification name] isEqualToString:@"Special Interest"]) {
        section = 5;
    } else if ([[notification name] isEqualToString:@"Student Activity"]) {
        section = 6;
    }
    
    // Scrolls to section
    CGRect sectionRect = [self.tableView rectForSection: section];
    sectionRect.size.height = self.tableView.frame.size.height;
        [self.tableView scrollRectToVisible:sectionRect animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) setSearchBarSettings
{
    // Initializes search bar settings
    [self.searchDisplayController.searchBar setTranslucent:NO];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage new]];
    [self.searchDisplayController.searchBar setBackgroundColor:[UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:57.0/255.0 alpha:1]];//[UIColor colorWithRed:2.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1]];
}

- (void) initializeNSNotificationObservers
{
    // Receives notification to scroll to section from map buttons
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Academic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Athletic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Cultural" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Performing Arts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Social Service" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Special Interest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:@"Student Activity" object:nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self setSearchBarSettings];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:220.0/255.0 green:180.0/255.0 blue:57.0/255.0 alpha:1]; // Gold
    [refreshControl addTarget:self action:@selector(refreshClubs) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

	//	NSArray * clubArray = [NSArray arrayWithObjects:[NSString stringWithString:@], nil];
	[(SAOTabBarController*)self.tabBarController setClubCategories: @[@"Academic",
												 @"Athletic",
												 @"Cultural",
												 @"Performing Arts",
												 @"Social Service",
												 @"Special Interest", @"Student Activity"]];
	[(SAOTabBarController*)self.tabBarController setClubs:nil];
    [self initializeNSNotificationObservers]; // Receives notification to scroll to section from map buttons
    
    
}

- (void)updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}



-(void)viewDidUnload
{
    // This will remove this object from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // Tab bar dark Blue; selected icon ND gold
    [[UITabBar appearance] setBarTintColor: [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:57.0/255.0 alpha:1]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:220.0/255.0 green:180.0/255.0 blue:57.0/255.0 alpha:1]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
								 sender:(id)sender {
    
	if ([segue.identifier isEqualToString:@"Club Detail Segue"]) {
		SAOClubNavigationController *destViewController = segue.destinationViewController;
		
		NSIndexPath *indexPath = nil;
		if ([self.searchDisplayController isActive])
		{
			indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
		}
		else
		{
			indexPath = [self.tableView indexPathForSelectedRow];
		}
		
		NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"Category", [(SAOTabBarController*)self.tabBarController clubCategories][indexPath.section]];
		
		NSArray *currentSectionClubs = [[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate];
		
		NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
		currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
		
		
		if ([self.searchDisplayController isActive]) {
			currentSectionClubs = [self.searchResults filteredArrayUsingPredicate:resultPredicate];
			currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
			
			destViewController.clubName = [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:indexPath.row] valueForKey:@"Name"];
			destViewController.clubDictionary = (NSMutableDictionary*)[currentSectionClubs objectAtIndex:indexPath.row];
			[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];

		} else {
			indexPath = [self.tableView indexPathForSelectedRow];
			destViewController.clubName = [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:indexPath.row] valueForKey:@"Name"];
			destViewController.clubDictionary = (NSMutableDictionary*)[currentSectionClubs objectAtIndex:indexPath.row];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

//Helper Methods
-(void)refreshClubs
{
//	[(SAOTabBarController*)self.tabBarController setClubs:[[NSMutableArray alloc] init]];
//	[(SAOTabBarController*)self.tabBarController setClubKeys:[[NSMutableArray alloc] init]];
	
    
	NSURLCache * cache = [NSURLCache sharedURLCache];
	[cache removeAllCachedResponses];

//	NSString *urlAddress = @"http://www.nd.edu/~sao/SAO_App/clubs.csv";
    NSString *urlAddress = @"http://www.nd.edu/~kngo/SAO_App/clubs.csv";
	NSURL *url = [NSURL URLWithString:urlAddress];

	SAOTabBarController * tabBarController = (SAOTabBarController*)self.tabBarController;
	if (tabBarController.parser.isParsing) {
		return;
	}
    
	tabBarController.parser = [[CSVParser alloc] init];
	tabBarController.parser.delegate = tabBarController;
	[tabBarController.parser loadCSVFileFromURL:url];
    
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:1];
}

-(void)viewDidAppear:(BOOL)animated
{
    // loading indicator
    if (!self.hasDataEverLoaded) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
        [self refreshClubs];
        [self performSelector:@selector(endRefreshing) withObject:nil
                   afterDelay:1.5];
        self.hasDataEverLoaded = YES;
    }
}

-(void)endRefreshing
{
    [self.refreshControl endRefreshing];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - UISearch Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"Name", searchText];
	
	self.searchResults = [[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return [[(SAOTabBarController*)self.tabBarController clubCategories] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"Category",
                                    [(SAOTabBarController*)self.tabBarController clubCategories][section]];

	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [[self.searchResults filteredArrayUsingPredicate:resultPredicate] count];
	} else {
		return [[[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate] count];
	}
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [(SAOTabBarController*)self.tabBarController clubCategories][section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"Club Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	
	NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"Category", [(SAOTabBarController*)self.tabBarController clubCategories][indexPath.section]];
	
	NSArray *currentSectionClubs = [[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate];
	
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		currentSectionClubs = [self.searchResults filteredArrayUsingPredicate:resultPredicate];
		currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

		NSInteger cellNumber = indexPath.row;
		cell.textLabel.text = [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:cellNumber] valueForKey:@"Name"];
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ cell.png", [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:cellNumber] valueForKey:@"Category"]]];
	} else {
		NSInteger cellNumber = indexPath.row;
		cell.textLabel.text = [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:cellNumber] valueForKey:@"Name"];
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ cell.png", [(SAOTabBarController*)self.tabBarController clubCategories][indexPath.section]]];
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier: @"Club Detail Segue" sender: self];
}

@end
