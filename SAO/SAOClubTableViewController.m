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

@end

@implementation SAOClubTableViewController

- (void) receiveTestNotification:(NSNotification *) notification
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
    }
    
    // Scrolls to section
    CGRect sectionRect = [self.tableView rectForSection: section];
    sectionRect.size.height = self.tableView.frame.size.height;
        [self.tableView scrollRectToVisible:sectionRect animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	NSArray * clubArray = [NSArray arrayWithObjects:[NSString stringWithString:@], nil];
	
	
	[(SAOTabBarController*)self.tabBarController setClubCategories: @[@"Academic",
												 @"Athletic",
												 @"Cultural",
												 @"Performing Arts",
												 @"Social Service",
												 @"Special Interest"]];
	[(SAOTabBarController*)self.tabBarController setClubs:nil];
	[self.tableView reloadData];
	[self refreshClubs];
    
    // Receives notification to scroll to section from map buttons
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"Academic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"Athletic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"Cultural" object:nil];
}

-(void)viewDidUnload
{
    // This will remove this object from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self refreshClubs];
	[super viewWillAppear:animated];
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
		
		NSPredicate *resultPredicate = [NSPredicate
																		predicateWithFormat:@"%K == %@", @"Category",
																		[(SAOTabBarController*)self.tabBarController clubCategories][indexPath.section]];
		
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

	NSString *urlAddress = @"http://www.nd.edu/~sao/SAO_App/clubs.csv";
//    NSString *urlAddress = @"http://www3.nd.edu/~kngo/clubs.csv";
	NSURL *url = [NSURL URLWithString:urlAddress];

	SAOTabBarController * tabBarController = (SAOTabBarController*)self.tabBarController;
	if (tabBarController.parser.isParsing) {
		return;
	}
	tabBarController.parser = [[CSVParser alloc] init];
	tabBarController.parser.delegate = tabBarController;
	[tabBarController.parser loadCSVFileFromURL:url];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - UISearch Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSPredicate *resultPredicate = [NSPredicate
																	predicateWithFormat:@"%K contains[cd] %@", @"Name",
																	searchText];
	
	self.searchResults = [[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString
														 scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
																		objectAtIndex:[self.searchDisplayController.searchBar
																									 selectedScopeButtonIndex]]];
	
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
	NSPredicate *resultPredicate = [NSPredicate
																	predicateWithFormat:@"%K == %@", @"Category",
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
	
	NSPredicate *resultPredicate = [NSPredicate
																	predicateWithFormat:@"%K == %@", @"Category",
																	[(SAOTabBarController*)self.tabBarController clubCategories][indexPath.section]];
	
	NSArray *currentSectionClubs = [[(SAOTabBarController*)self.tabBarController clubs] filteredArrayUsingPredicate:resultPredicate];
	
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		currentSectionClubs = [self.searchResults filteredArrayUsingPredicate:resultPredicate];
		currentSectionClubs=[currentSectionClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

		int cellNumber = indexPath.row;
		cell.textLabel.text = [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:cellNumber] valueForKey:@"Name"];
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ cell.png", [(NSMutableDictionary*)[currentSectionClubs objectAtIndex:cellNumber] valueForKey:@"Category"]]];
	} else {
		int cellNumber = indexPath.row;
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
