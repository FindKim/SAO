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
//@property (nonatomic, strong) UIButton *buttonContainer;
@property (nonatomic, assign) BOOL mapLoaded;

@end

@implementation SAOClubMapViewController


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
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first time to map"])
	{
		[self promptDoubleTapMapInstructions];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first time to map"];
	}
}

-(void) promptDoubleTapMapInstructions
{
    UIAlertView * noSavedOrderAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Zoom in to double tap on tables for more information!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    noSavedOrderAlertView.delegate = self;
    [noSavedOrderAlertView show];
}


-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

//////Helper Methods//////

-(void)resetMapScrollViewWithNewImage
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
	double scale = MAX(self.mapScrollView.frame.size.width / self.mapImage.size.width * 0.9, self.mapScrollView.frame.size.height / self.mapImage.size.height * 0.9);
    
	self.mapScrollView.minimumZoomScale = scale;
	self.mapScrollView.delegate = self;
    
	for (UIView * subView in [self.mapScrollView subviews])
	{
        [subView removeFromSuperview];
	}
    
	self.mapImageView = [[UIImageView alloc] initWithImage:self.mapImage];
    
    CGFloat offsetX = (self.mapImage.size.width/2 - self.mapScrollView.bounds.size.width/2);
    
	self.mapImageView.frame = CGRectMake(0, 0, self.mapImage.size.width, self.mapImage.size.height);
    [self.mapScrollView setContentOffset:CGPointMake(offsetX, 0)];  // Center of image is displayed
	[self.mapScrollView addSubview:self.mapImageView];
	self.mapScrollView.contentSize = self.mapImage.size;
    //
    //	CGFloat offsetX = 	(self.mapScrollView.bounds.size.width - self.mapScrollView.contentSize.width) * 0.5;
    //
    //	CGFloat offsetY =	(self.mapScrollView.bounds.size.height - self.mapScrollView.contentSize.height) * 0.5;
    //
    //	self.mapImageView.center = CGPointMake(self.mapScrollView.contentSize.width * 0.5 + offsetX,
    //															 self.mapScrollView.contentSize.height * 0.5 + offsetY);
	self.mapScrollView.maximumZoomScale = 1;
    self.mapScrollView.minimumZoomScale = 0.4;
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
    NSMutableArray* buttonContainer = [[NSMutableArray alloc] init];
    
    NSMutableArray* academicButtonLocations = [[NSMutableArray alloc] init];
    [academicButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(100,755,1400,40)]];
    [academicButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(125,700,400,60)]];
    
    NSMutableArray* athleticButtonLocations = [[NSMutableArray alloc] init];
    [athleticButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(540, 710, 950, 40)]];
    [athleticButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(1275, 650, 200, 60)]];
    
    NSMutableArray* culturalButtonLocations = [[NSMutableArray alloc] init];
    [culturalButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(400, 650, 850, 40)]];
    
    NSMutableArray* performingArtsButtonLocations = [[NSMutableArray alloc] init];
    [performingArtsButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(125, 595, 550, 50)]];
    [performingArtsButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(125, 640, 240, 50)]];
    
    NSMutableArray* socialServiceButtonLocations = [[NSMutableArray alloc] init];
    [socialServiceButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(690, 530, 800, 100)]];
    
    NSMutableArray* specialInterestButtonLocations = [[NSMutableArray alloc] init];
    [specialInterestButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(350, 325, 60, 150)]];
    [specialInterestButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(400, 470, 800, 60)]];
    [specialInterestButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(125, 530, 500, 60)]];
    
    NSMutableArray* studentActivityButtonLocations = [[NSMutableArray alloc] init];
    [studentActivityButtonLocations addObject:[NSValue valueWithCGRect:CGRectMake(1500, 440, 80, 400)]];
    
    // x, y, width, height
    for (int i = 0; i < [academicButtonLocations count]; i++) {
        UIButton *Academic = [UIButton buttonWithType:UIButtonTypeCustom];
        Academic.frame = [[academicButtonLocations objectAtIndex:i] CGRectValue];
        Academic.tag = 0;
        [Academic addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Academic];
    }
    
    for (int i = 0; i < [athleticButtonLocations count]; i++) {
        UIButton *Athletic = [UIButton buttonWithType:UIButtonTypeCustom];
        Athletic.frame = [[athleticButtonLocations objectAtIndex:i] CGRectValue];
        Athletic.tag = 1;
        [Athletic addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Athletic];
    }
    
    for (int i = 0; i < [culturalButtonLocations count]; i++) {
        UIButton *Cultrual = [UIButton buttonWithType:UIButtonTypeCustom];
        Cultrual.frame = [[culturalButtonLocations objectAtIndex:i] CGRectValue];
        Cultrual.tag = 2;
        [Cultrual addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Cultrual];
    }
    
    for (int i = 0; i < [performingArtsButtonLocations count]; i++) {
        UIButton *PerformingArts = [UIButton buttonWithType:UIButtonTypeCustom];
        PerformingArts.frame = [[performingArtsButtonLocations objectAtIndex:i] CGRectValue];
        PerformingArts.tag = 3;
        [PerformingArts addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:PerformingArts];
    }
    
    for (int i = 0; i < [socialServiceButtonLocations count]; i++) {
        UIButton *SocialService = [UIButton buttonWithType:UIButtonTypeCustom];
        SocialService.frame = [[socialServiceButtonLocations objectAtIndex:i] CGRectValue];
        SocialService.tag = 4;
        [SocialService addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:SocialService];
    }
    
    for (int i = 0; i < [specialInterestButtonLocations count]; i++) {
        UIButton *SpecialInterest = [UIButton buttonWithType:UIButtonTypeCustom];
        SpecialInterest.frame = [[specialInterestButtonLocations objectAtIndex:i] CGRectValue];
        SpecialInterest.tag = 5;
        [SpecialInterest addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:SpecialInterest];
    }
    
    for (int i = 0; i < [studentActivityButtonLocations count]; i++) {
        UIButton *StudentActivity = [UIButton buttonWithType:UIButtonTypeCustom];
        StudentActivity.frame = [[studentActivityButtonLocations objectAtIndex:i] CGRectValue];
        StudentActivity.tag = 6;
        [StudentActivity addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:StudentActivity];
    }
    
    
    
    for (UIButton *button in buttonContainer) {
        [self.mapImageView addSubview:button];
        [self.mapImageView bringSubviewToFront:button];
    }
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
    //"http://www.nd.edu/~sao/SAO_App/SAO_Map.jpg"
    [NSURLConnection connectionWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.nd.edu/~kngo/SAO_App/SAO_Map.jpg"]] delegate:(SAOTabBarController*)self.tabBarController];
    NSLog(@"this is trying to dl image");
    
}

//////Finish Helper Methods//////

@end