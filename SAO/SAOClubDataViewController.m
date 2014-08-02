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

//@property (weak, nonatomic) IBOutlet UILabel *clubDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *clubImageView;
@property (weak, nonatomic) IBOutlet UITextView *clubDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *clubNameLabel;


@end

@implementation SAOClubDataViewController

- (IBAction)cancelButtonPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
    self.clubNameLabel.text =[(SAOClubNavigationController* )self.navigationController clubName];
	self.navigationItem.title =[[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Category"];
	self.clubDescriptionTextView.text = [[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Description"];
	self.clubImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Category"]]];
	
    [self.navigationController.navigationBar setTranslucent:NO];
	[self fillFavoritedStar];
}

-(void)fillFavoritedStar
{
	if ([[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] valueForKey:self.clubNameLabel.text])
	{
        // Changes star color from gray to yellow/orange to match "contact" button
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:240.0/255 green:168.0/255 blue:4.0/255 alpha:1];
	} else {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
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
	
	if(![[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] valueForKey:self.clubNameLabel.text])
	{
		NSDictionary * clubDictionary = [[(SAOClubNavigationController*)self.navigationController clubDictionary] copy];
		NSMutableDictionary * favoriteClubsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] mutableCopy];
		[favoriteClubsDictionary setValue:clubDictionary forKey:self.clubNameLabel.text];
		[[NSUserDefaults standardUserDefaults] setValue:[favoriteClubsDictionary copy] forKey:FAVORITE_CLUBS];
	} else {
		NSMutableDictionary * favoriteClubsDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITE_CLUBS] mutableCopy];
		[favoriteClubsDictionary removeObjectForKey:self.clubNameLabel.text];
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
	NSString *emailTitle = [NSString stringWithFormat:@"Interested in %@", self.clubNameLabel.text];
	// Email Content
	NSString *messageBody;
    
    if ([name length] > 0) {
        
        if ([class length] > 0) {
	        
	    	if ([class rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound) {
	            
	    		// Class year & major
	    		if ([major length] > 0) {
	    			messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@; I am a %@ major in the class of %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, major, class, self.clubNameLabel.text, name];
	                
	                // Class year & no major
		    	} else {
		    		messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and I am in the class of %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, class, self.clubNameLabel.text, name];
		    	}
	            
	    	} else {
	            
	    		// Class category & major
	    		if ([major length] > 0) {
	    			messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and I am a %@ %@ major. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, class, major, self.clubNameLabel.text, name];
	                
                // Class category & no major
	    		} else {
	    			messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and I am currently a %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, class, self.clubNameLabel.text, name];
	    		}
	            
	    	}
	        
        // No class & major
	    } else if ([major length] > 0) {
	        messageBody = [NSString stringWithFormat:@"Hi,\n\n My name is %@ and my major is %@. Can you send me more information about the %@?\n\n\nThanks,\n\n%@", name, major, self.clubNameLabel.text, name];
        }

    } else {
    	messageBody = [NSString stringWithFormat:@"Can you send me more information about the %@?\n", self.clubNameLabel.text];
    }
    
	// To address
	NSArray *toRecipents = [NSArray arrayWithObject:[[(SAOClubNavigationController* )self.navigationController clubDictionary] valueForKey:@"Email"]];
	
    // Setting navigation bar to white -- because cannot change MailComposerVC's navigation bar or status bar to blue & white respectively
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];

	MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    mc.mailComposeDelegate = self;
	[mc setSubject:emailTitle];
	[mc setMessageBody:messageBody isHTML:NO];
	[mc setToRecipients:toRecipents];
	
	// Present mail view controller on screen
	[self presentViewController:mc animated:YES completion:NULL];
    
    // Changing navigation bar back to ND Blue
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:2.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1];
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
