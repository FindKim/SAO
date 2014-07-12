//
//  SAOClubDataViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/21/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "SAOClubDataViewController.h"
#import "SAOClubNavigationController.h"

#define MAJOR (@"major")
#define NAME (@"name")
#define EMAIL (@"email")
#define CLASS (@"class")
#define FAVORITE_CLUBS (@"favorite clubs")

@interface SAOClubDataViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *clubDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *clubImageView;

@end

@implementation SAOClubDataViewController

- (IBAction)cancelButtonPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	self.navigationItem.title = [(SAOClubNavigationController* )self.navigationController clubName];
	self.clubDescriptionTextView.text = [[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Description"];
	self.clubImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Category"]]];
	
	[self fillFavoritedStar];
}

-(void)fillFavoritedStar
{
	if ([[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] valueForKey:self.navigationItem.title])
	{
		self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"FilledStar.png"];
	} else {
		self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"EmptyStar.png"];
	}
}
- (IBAction)favoriteCurrentClub:(UIBarButtonItem *)sender
{
	//build the dictionary of favorite clubs if one hasn't been saved before
	if(![[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS])
	{
		[[NSUserDefaults standardUserDefaults] setValue:[[NSDictionary alloc] init] forKey:FAVORITE_CLUBS];
	}
	
	if(![[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] valueForKey:self.navigationItem.title])
	{
		NSDictionary * clubDictionary = [[(SAOClubNavigationController*)self.navigationController clubDictionary] copy];
		NSMutableDictionary * favoriteClubsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] mutableCopy];
		[favoriteClubsDictionary setValue:clubDictionary forKey:self.navigationItem.title];
		[[NSUserDefaults standardUserDefaults] setValue:[favoriteClubsDictionary copy] forKey:FAVORITE_CLUBS];
	} else {
		NSMutableDictionary * favoriteClubsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] mutableCopy];
		[favoriteClubsDictionary removeObjectForKey:self.navigationItem.title];
		[[NSUserDefaults standardUserDefaults] setValue:[favoriteClubsDictionary copy] forKey:FAVORITE_CLUBS];
	}
	
	
	
	[self fillFavoritedStar];
}
- (IBAction)contactButtonTapped:(UIButton *)sender
{
	NSString * name  = [[NSUserDefaults standardUserDefaults] objectForKey:NAME];
	NSString * major = [[NSUserDefaults standardUserDefaults] objectForKey:MAJOR];
    NSString * class = [[NSUserDefaults standardUserDefaults] objectForKey:CLASS];
	
	// Email Subject
	NSString *emailTitle = [NSString stringWithFormat:@"Interested in %@", self.navigationItem.title];
	// Email Content
	NSString *messageBody;
    
    if (name && major && class)
    {
        if (class.length > 0 && [class rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound)
        {
            messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@, my major is %@, and I am in the class of %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, major, class, self.navigationItem.title, name];

        } else {
            messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and I am a %@ %@ major. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, class, major, self.navigationItem.title, name];
        }
    }
    else if (name && major && !class)
    {
        messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and my major is %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, major, self.navigationItem.title, name];
    }
    else if (!name || !major)
    {
        messageBody = nil;
    }
	// To address
	NSArray *toRecipents = [NSArray arrayWithObject:[[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Email"]];
	
	MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
	mc.mailComposeDelegate = self;
	[mc setSubject:emailTitle];
	[mc setMessageBody:messageBody isHTML:NO];
	[mc setToRecipients:toRecipents];
	
	// Present mail view controller on screen
	[self presentViewController:mc animated:YES completion:NULL];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail sent failure: %@", [error localizedDescription]);
			break;
		default:
			break;
	}
	
	// Close the Mail Interface
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
