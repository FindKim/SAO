//
//  SAOProfileViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/21/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOProfileViewController.h"
#import "SAOClubNavigationController.h"

#define FAVORITE_CLUBS (@"favorite clubs")
#define MAJOR (@"major")
#define NAME (@"name")
#define CLASS (@"class")

@interface SAOProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UITableView *favoriteClubsTableView;
@property (nonatomic, strong) NSArray * favoriteClubs;

@end

@implementation SAOProfileViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad
{	
	[super viewDidLoad];
    
    //set the table delegate and data source
	self.favoriteClubsTableView.delegate = self;
	self.favoriteClubsTableView.dataSource = self;
    [self setNeedsStatusBarAppearanceUpdate];
}


// Ensures classLabel is short in characters
// Accounts for class category or class year
-(NSString *)abbreviateClass
{
    NSString *class = [[NSUserDefaults standardUserDefaults] valueForKey:CLASS];

    // Class category
    // [Ff]: freshman; [So]: sophomore; [Jj]: junior; [Ss]enior
    if (class == NULL) {
        class = @"";

    } else if ([class rangeOfString:@"f" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        class = @"Fr";

    } else if ([class rangeOfString:@"so" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        class = @"Soph";

    } else if ([class rangeOfString:@"j" options: NSCaseInsensitiveSearch].location != NSNotFound) {
        class = @"Jr";
        
    } else if ([class rangeOfString:@"senior" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        class = @"Sr";

    }
    return class;
}

-(void)viewWillAppear:(BOOL)animated
{
    // Tab bar ND Blue; selected icon ND gold
    [[UITabBar appearance] setBarTintColor: [UIColor colorWithRed:2.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:220.0/255.0 green:180.0/255.0 blue:57.0/255.0 alpha:1]];
    
    
	self.nameLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:NAME];
	self.majorLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:MAJOR];
	self.classLabel.text = self.abbreviateClass;

	//get all the favorited clubs from NSUserDefaults
	self.favoriteClubs = [[[NSUserDefaults standardUserDefaults] valueForKey:FAVORITE_CLUBS] allValues];

	[self.favoriteClubsTableView reloadData];
	[super viewWillAppear:animated];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.favoriteClubs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"Profile Club Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	
	int cellNumber = indexPath.row;
	cell.textLabel.text = [(NSMutableDictionary*)[self.favoriteClubs objectAtIndex:cellNumber] valueForKey:@"Name"];
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ cell.png", [(NSMutableDictionary*)[self.favoriteClubs objectAtIndex:cellNumber] valueForKey:@"Category"]]];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier: @"Club Detail Segue" sender: self];
	[self.favoriteClubsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Club Detail Segue"]) {
		SAOClubNavigationController *destViewController = segue.destinationViewController;
        
		NSIndexPath *indexPath = nil;
        
		indexPath = [self.favoriteClubsTableView indexPathForSelectedRow];
		destViewController.clubName = [(NSMutableDictionary*)[self.favoriteClubs objectAtIndex:indexPath.row] valueForKey:@"Name"];
		destViewController.clubDictionary = [(NSMutableDictionary*)[self.favoriteClubs objectAtIndex:indexPath.row] copy];
	}
}

@end
