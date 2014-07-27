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
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIImageView *mapImageView;
@property (weak, nonatomic) UIButton *testButton;
@property (nonatomic, strong) UIButton *buttonContainer;
@property (nonatomic, assign) BOOL mapLoaded;

@end

@implementation SAOClubMapViewController


- (void)didTouchDownOnButton:(UIButton *)button
{
    // Highlight on touch down
    NSLog(@"Button %ld", (long)button.tag);
}


-(void) handleDoubleTap: (UIButton *)button//(UIGestureRecognizer *) gestureRecognizer
{
    NSLog(@"Double tap working");
    
    NSString *clubCategory;
    NSInteger clubCategoryID = button.tag;
    
    if (clubCategoryID == 0) {
        clubCategory = @"Academic";
    } else if (clubCategoryID == 1) {
        clubCategory = @"Athletic";
    } else if (clubCategoryID == 2) {
        clubCategory = @"Cultural";
    } else if (clubCategoryID == 3) {
        clubCategory = @"Performing Arts";
    } else if (clubCategoryID == 4) {
        clubCategory = @"Social Service";
    } else if (clubCategoryID == 5) {
        clubCategory = @"Special Interest";
    } else if (clubCategoryID == 6) {
        clubCategory = @"Student Activity";
    }
    
    NSLog(@"Sending category %@", clubCategory);
    
    // Sends notification to ClubsTableView
    [[NSNotificationCenter defaultCenter]
     postNotificationName: clubCategory object:nil];
    // Changes tabs to ClubsTableView
    [self.tabBarController setSelectedIndex:2];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    // Add activity indicator to load map
    CGRect frame = CGRectMake (100, 100, 80, 80);
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.activityIndicatorView];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	//request for the map from online
    if (!self.mapLoaded) {
        
        // Added activity indicator to load new map
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self requestNewMap];
        [self.view bringSubviewToFront:self.activityIndicatorView];
        self.mapLoaded = YES;
        
        // Stop animating after map is requested
        [self.activityIndicatorView stopAnimating];
    }
}

-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
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
    
    [self addCategoryButtonsToScrollView];
    [self scaleButtonToSize: self.testButton];
    
    // Allows views to receive touch gestures -- UIScrollView blocks by default
    self.mapScrollView.userInteractionEnabled = YES;
    self.mapImageView.userInteractionEnabled = YES;
    self.mapScrollView.exclusiveTouch = YES;
    self.mapImageView.exclusiveTouch = YES;
}

-(void) addCategoryButtonsToScrollView
{
    // x, y, width, height
    //    UIImage *Img = [UIImage imageNamed:@"FilledStar.png"];
    
    UIButton *Academic = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect academicFrame = CGRectMake(100, 750, 1400, 40);
    Academic.frame = academicFrame;
    Academic.tag = 0;
    //    [Academic setBackgroundImage:Img forState:UIControlStateNormal];
    [Academic addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
    [self.mapImageView addSubview:Academic];
    [self.mapImageView bringSubviewToFront:Academic];
    
    UIButton *Athletic = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect athleticFrame = CGRectMake(400, 450, 800, 50);
    Athletic.frame = athleticFrame;
    Athletic.tag = 1;
    //    [Athletic setBackgroundImage:Img forState:UIControlStateNormal];
    [Athletic addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
    [self.mapImageView addSubview:Athletic];
    [self.mapImageView bringSubviewToFront:Athletic];
    
    UIButton *Cultural = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect culturalFrame = CGRectMake(370, 650, 1000, 40);
    Cultural.frame = culturalFrame;
    Cultural.tag = 2;
    //    [Cultural setBackgroundImage:Img forState:UIControlStateNormal];
    [Cultural addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
    [self.mapImageView addSubview:Cultural];
    [self.mapImageView bringSubviewToFront:Cultural];
}


-(void)scaleButtonToSize:(UIButton *)button
{
    double scale = self.mapScrollView.zoomScale;
    
    int x = button.frame.origin.x;
    int y = button.frame.origin.y;
    int width = button.frame.size.width;
    int height = button.frame.size.height;
    
    CGRect Frame = CGRectMake(x, y, width*scale, height*scale);
    button.frame = Frame;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.mapImageView;
}

-(void)requestNewMap
{
	//start with a clean slate
	[(SAOTabBarController*)self.tabBarController setReceivedData: [[NSMutableData alloc] init]];
    
	//make the request in the background
    [[NSURLConnection alloc] initWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.nd.edu/~sao/SAO_App/SAO_Map.jpg"]] delegate:(SAOTabBarController*)self.tabBarController];
    NSLog(@"this is trying to dl image");
    
}

//////Finish Helper Methods//////

@end