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

-(void) handleDoubleTapPartnerTable: (UIButton *)button
{
    NSInteger linkID = button.tag;
    NSURL *url;
    
    if (linkID == 0) {
        NSLog(@"Link to Community Partners");
        url = [NSURL URLWithString:@"http://www.nd.edu/~kngo"];
        
    } else if (linkID == 1) {
        NSLog(@"Link to Campus Partners");
        url = [NSURL URLWithString:@"http://google.com"];
    }
    
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}



-(void) handleDoubleTapClubTable: (UIButton *)button//(UIGestureRecognizer *) gestureRecognizer
{
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
    
//    NSLog(@"Sending category %@", clubCategory);
    
    // Sends notification to ClubsTableView
    [[NSNotificationCenter defaultCenter]
     postNotificationName: clubCategory object:nil];
    // Changes tabs to ClubsTableView
    [self.tabBarController setSelectedIndex:2];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    // Add activity indicator to load map
    CGRect frame = CGRectMake (100, 100, 80, 80);
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.activityIndicatorView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    //request for the map from online
    if (!self.mapLoaded) {
        
        // Added activity indicator to load new map
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //        Use requestNewMap if downloading from url
        //        [self requestNewMap];
        // Static map with static button locations
        self.mapImage = [UIImage imageNamed:@"SAO_Map.png"];
        [self resetMapScrollViewWithNewImage];
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

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void) promptDoubleTapMapInstructions
{
    UIAlertView * noSavedOrderAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Double tap on tables for more information!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    noSavedOrderAlertView.delegate = self;
    [noSavedOrderAlertView show];
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    // Centers image while zooming
    CGSize imgViewSize = self.mapImageView.frame.size;
    CGSize imageSize = self.mapImageView.image.size;
    
    CGSize realImgSize;
    if(imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height) {
        realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height);
    }
    else {
        realImgSize = CGSizeMake(imgViewSize.height / imageSize.height * imageSize.width, imgViewSize.height);
    }
    
    CGRect fr = CGRectMake(0, 0, 0, 0);
    fr.size = realImgSize;
    self.mapImageView.frame = fr;
    
    CGSize scrSize = scrollView.frame.size;
    float offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0);
    float offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 - 30 : 0);
    
    // don't animate the change.
    scrollView.contentInset = UIEdgeInsetsMake(offy, offx, offy, offx);
}


-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

//////Helper Methods//////

-(void)resetMapScrollViewWithNewImage
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
	double scale = MAX(self.mapScrollView.frame.size.width / self.mapImage.size.width * 0.80, self.mapScrollView.frame.size.height / self.mapImage.size.height * 0.80);
    
	self.mapScrollView.minimumZoomScale = scale;
	self.mapScrollView.delegate = self;
    
	for (UIView * subView in [self.mapScrollView subviews])
	{
        [subView removeFromSuperview];
	}
    
	self.mapImageView = [[UIImageView alloc] initWithImage:self.mapImage];
	self.mapImageView.frame = CGRectMake(0, 0, self.mapImage.size.width, self.mapImage.size.height);
    // Center of image is displayed
	self.mapScrollView.contentSize = self.mapImage.size;

    // Offset depending on phone-bit--I don't understand why
    CGFloat offsetX;
    if (sizeof(void*) == 4) {   // 32-bit offset = 320
        offsetX = (self.mapScrollView.contentSize.width * 0.5 - self.mapScrollView.bounds.size.width * 0.5);
        
    } else if (sizeof(void*) == 8) {    // 64-bit offset = 216.96 (scaled)
        offsetX = (scale * self.mapScrollView.contentSize.width * 0.5 - self.mapScrollView.bounds.size.width * 0.5);
    }

    [self.mapScrollView setContentOffset:CGPointMake(offsetX, 0)];
	[self.mapScrollView addSubview:self.mapImageView];
	
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
        [Academic addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Academic];
    }
    
    for (int i = 0; i < [athleticButtonLocations count]; i++) {
        UIButton *Athletic = [UIButton buttonWithType:UIButtonTypeCustom];
        Athletic.frame = [[athleticButtonLocations objectAtIndex:i] CGRectValue];
        Athletic.tag = 1;
        [Athletic addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Athletic];
    }
    
    for (int i = 0; i < [culturalButtonLocations count]; i++) {
        UIButton *Cultrual = [UIButton buttonWithType:UIButtonTypeCustom];
        Cultrual.frame = [[culturalButtonLocations objectAtIndex:i] CGRectValue];
        Cultrual.tag = 2;
        [Cultrual addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:Cultrual];
    }
    
    for (int i = 0; i < [performingArtsButtonLocations count]; i++) {
        UIButton *PerformingArts = [UIButton buttonWithType:UIButtonTypeCustom];
        PerformingArts.frame = [[performingArtsButtonLocations objectAtIndex:i] CGRectValue];
        PerformingArts.tag = 3;
        [PerformingArts addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:PerformingArts];
    }
    
    for (int i = 0; i < [socialServiceButtonLocations count]; i++) {
        UIButton *SocialService = [UIButton buttonWithType:UIButtonTypeCustom];
        SocialService.frame = [[socialServiceButtonLocations objectAtIndex:i] CGRectValue];
        SocialService.tag = 4;
        [SocialService addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:SocialService];
    }
    
    for (int i = 0; i < [specialInterestButtonLocations count]; i++) {
        UIButton *SpecialInterest = [UIButton buttonWithType:UIButtonTypeCustom];
        SpecialInterest.frame = [[specialInterestButtonLocations objectAtIndex:i] CGRectValue];
        SpecialInterest.tag = 5;
        [SpecialInterest addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:SpecialInterest];
    }
    
    for (int i = 0; i < [studentActivityButtonLocations count]; i++) {
        UIButton *StudentActivity = [UIButton buttonWithType:UIButtonTypeCustom];
        StudentActivity.frame = [[studentActivityButtonLocations objectAtIndex:i] CGRectValue];
        StudentActivity.tag = 6;
        [StudentActivity addTarget:self action:@selector(handleDoubleTapClubTable:)     forControlEvents:UIControlEventTouchDownRepeat];
        [buttonContainer addObject:StudentActivity];
    }
    
    
//    // Partner links
//    UIButton *CommunitPartners = [UIButton buttonWithType:UIButtonTypeCustom];
//    CommunitPartners.frame = CGRectMake(1200, 175, 200, 300);
//    CommunitPartners.tag = 0;
//    [CommunitPartners addTarget:self action:@selector(handleDoubleTapPartnerTable:) forControlEvents:UIControlEventTouchDownRepeat];
//    [buttonContainer addObject:CommunitPartners];
//    
//    
//    NSMutableArray* campusPartnersLocation = [[NSMutableArray alloc] init];
//    [campusPartnersLocation addObject:[NSValue valueWithCGRect:CGRectMake(200, 175, 200, 125)]];
//    [campusPartnersLocation addObject:[NSValue valueWithCGRect:CGRectMake(200, 300, 150, 175)]];
//    
//    for (int i = 0; i < [campusPartnersLocation count]; i++) {
//        UIButton *CampusPartners = [UIButton buttonWithType:UIButtonTypeCustom];
//        CampusPartners.frame = [[campusPartnersLocation objectAtIndex:i] CGRectValue];
//        CampusPartners.tag = 1;
//        [CampusPartners addTarget:self action:@selector(handleDoubleTapPartnerTable:) forControlEvents:UIControlEventTouchDownRepeat];
//        [buttonContainer addObject:CampusPartners];
//    }
    
    
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
    [NSURLConnection connectionWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.nd.edu/~sao/SAO_App/SAO_Map.png"]] delegate:(SAOTabBarController*)self.tabBarController];
    NSLog(@"this is trying to dl image");
    
}

//////Finish Helper Methods//////

@end