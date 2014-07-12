//
//  SAOClubMapViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/26/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOClubMapViewController.h"
#import "SAOTabBarController.h"

@interface SAOClubMapViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, strong) UIImageView * mapImageView;

@end

@implementation SAOClubMapViewController

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//request for the map from online
	[self requestNewMap];
	
}

//////Helper Methods//////

-(void)resetMapScrollViewWithNewImage
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	double scale = MAX(self.mapScrollView.frame.size.width / self.mapImage.size.width,
										 self.mapScrollView.frame.size.height / self.mapImage.size.height);
	
	self.mapScrollView.minimumZoomScale = scale;
	self.mapScrollView.delegate = self;
	
	for (UIView * subView in [self.mapScrollView subviews])
	{
    [subView removeFromSuperview];
	}
	
	self.mapImageView = [[UIImageView alloc] initWithImage:self.mapImage];
	
	self.mapImageView.frame = CGRectMake(0,
																			 0,
																			 self.mapImage.size.width,
																			 self.mapImage.size.height);
	[self.mapScrollView addSubview:self.mapImageView];
	self.mapScrollView.contentSize = self.mapImage.size;
//	
//	CGFloat offsetX = 	(self.mapScrollView.bounds.size.width - self.mapScrollView.contentSize.width) * 0.5;
//	
//	CGFloat offsetY =	(self.mapScrollView.bounds.size.height - self.mapScrollView.contentSize.height) * 0.5;
//	
//	self.mapImageView.center = CGPointMake(self.mapScrollView.contentSize.width * 0.5 + offsetX,
//															 self.mapScrollView.contentSize.height * 0.5 + offsetY);
	self.mapScrollView.zoomScale = scale;
		
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.mapImageView;
}

-(void)requestNewMap
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//start with a clean slate
	[(SAOTabBarController*)self.tabBarController setReceivedData: [[NSMutableData alloc] init]];
	
	//make the request in the background
	[[NSURLConnection alloc] initWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.nd.edu/~sao/SAO_App/SAO_Map.jpg"]] delegate:(SAOTabBarController*)self.tabBarController];
}

//////Finish Helper Methods//////

@end
