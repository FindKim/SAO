//
//  SAOViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/15/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOViewController.h"
#import "CSVParser.h"
#import <QuartzCore/QuartzCore.h>
#import "SAOTappableView.h"

@interface SAOViewController () <UIAlertViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *homeScrollView;

@property (strong, nonatomic) UIImageView *homeImageView;

@property (nonatomic, strong) NSArray * viewArray;
@property (nonatomic, strong) NSArray * linkArray;

@end

@implementation SAOViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first app opening"])
	{
		[self promptForLogin];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first app opening"];
	}
	
	self.homeScrollView.delegate = self;
	
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)promptForLogin
{
	UIAlertView * noSavedOrderAlertView = [[UIAlertView alloc] initWithTitle:@"Welcome!"
																																	 message:@"Please sign in."
																																	delegate:self
																												 cancelButtonTitle:@"Cancel"
																												 otherButtonTitles:@"Sign In", nil];
	noSavedOrderAlertView.delegate = self;
	[noSavedOrderAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([alertView.title isEqualToString:@"Welcome!"] &&
			buttonIndex == 1)
	{
		[self performSegueWithIdentifier:@"Sign In Segue" sender:self];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	//set up the scroll view
	//	-make an imageview with the correct iamge, frame, and add it as a subview
	//	-make the imageView as big as the image it holds
	//	-make sure that the scroll view content size is set to the same
	
	
	
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	if (screenBounds.size.height == 568) {
		self.homeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SAO-Tab-Long-png.png"]];
	} else {
		self.homeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SAO-Tab-png.png"]];
	}
	
	self.homeImageView.frame = CGRectMake(0,
																				0,
																				self.homeImageView.image.size.width,
																				self.homeImageView.image.size.height);
	[self.homeScrollView addSubview:self.homeImageView];
	
	self.homeScrollView.contentSize = self.homeImageView.frame.size;
	
	/*
	 
	 location of the links on the smaller screen home screen
	 
	 Important Places	32, 450, 36, 36 - http://www.nd.edu/
	 Residence Halls	32, 494, 36, 36 - http://housing.nd.edu/
	 Green Space	32, 539, 36, 36 - http://green.nd.edu/campus-ecology/
	 Miscellaneous	32, 584, 36, 36 - http://www.nd.edu/about/history/
	 
	 Academics	174, 450, 36, 36 - http://www.nd.edu/academics/
	 Athletics	174, 494, 36, 36 - http://www.und.com/
	 Water	174, 539, 36, 36 - http://green.nd.edu/strategy/water/
	 Parking Lots	174, 584, 36, 36 - http://ndsp.nd.edu/parking-and-traffic/
	 
	 facebook	196, 43, 46, 46 - https://www.facebook.com/saond
	 Twitter	247, 43, 46, 46 - https://twitter.com/saond
	 homepage	31, 39, 74, 55 - http://sao.nd.edu/
	 
	 */
	
	NSArray * tappableViewArray = @[[[SAOTappableView alloc] initWithFrame:CGRectMake(36, 430, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(36, 474, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(36, 519, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(36, 564, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(174, 430, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(174, 474, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(174, 519, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(174, 564, 36, 36)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(196, 23, 46, 46)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(247, 23, 46, 46)],
																 [[SAOTappableView alloc] initWithFrame:CGRectMake(30, 9, 75, 55)]];
	if (screenBounds.size.height == 568)
	{
        NSLog(@"IN HERE");
		tappableViewArray = @[[[SAOTappableView alloc] initWithFrame:CGRectMake(32, 520, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(32, 562, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(32, 605, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(32, 646, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(171, 520, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(171, 562, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(171, 605, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(171, 646, 36, 36)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(188, 30, 51, 51)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(246, 30, 51, 51)],
												[[SAOTappableView alloc] initWithFrame:CGRectMake(38, 20, 80, 60)]];
		
	}
	NSArray * linkArray = @[@"http://www.nd.edu/",
												 @"http://housing.nd.edu/",
												 @"http://green.nd.edu/campus-ecology/",
												 @"http://www.nd.edu/about/history/",
												 @"http://www.nd.edu/academics/",
												 @"http://www.und.com/",
												 @"http://green.nd.edu/strategy/water/",
												 @"http://ndsp.nd.edu/parking-and-traffic/",
												 @"https://www.facebook.com/saond",
												 @"https://twitter.com/saond",
												 @"http://sao.nd.edu/"];
	
	self.linkArray = linkArray;
	
	self.viewArray = tappableViewArray;
	
	for (int i = 0; i < [tappableViewArray count] - 1; i++)
	{
		UIView * view = (UIView*)tappableViewArray[i];
		view.layer.cornerRadius = 18;
		if (i >= [tappableViewArray count] - 3)
		{
			view.layer.cornerRadius = 23;
		}
	}
	
	for (UIView* view in tappableViewArray)
	{
    [self.homeScrollView addSubview:view];
		//		view.backgroundColor = [UIColor blackColor];
		//		view.alpha = 0.5;
		view.userInteractionEnabled = YES;
		UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewGotTapped:)];
		[view addGestureRecognizer:tapRecognizer];
	}
	
	if (screenBounds.size.height == 568) {
		self.homeScrollView.minimumZoomScale = 0.5;
		self.homeScrollView.maximumZoomScale = 0.5;
		self.homeScrollView.zoomScale = 0.5;
	}
	
	[super viewWillAppear:animated];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.homeImageView;
}

-(void)viewWillDisappear:(BOOL)animated
{
	for (UIView* view in self.viewArray)
	{
    [view removeFromSuperview];
	}
	
	[super viewWillDisappear:animated];
}

-(void)viewGotTapped:(UITapGestureRecognizer*)tapGesture
{
	CGPoint location = [tapGesture locationInView:self.homeScrollView];
	int linkIndex = 0;
	
	for (int i = 0; i < [self.viewArray count]; i++)
	{
		if (CGRectContainsPoint([(UIView*)self.viewArray[i] frame], location))
		{
			linkIndex = i;
			break;
		}
	}
	
	NSURL *url = [NSURL URLWithString:self.linkArray[linkIndex]];
	
	if (![[UIApplication sharedApplication] openURL:url])
		NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

@end
