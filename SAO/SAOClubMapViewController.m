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
@property (nonatomic, strong) UIImageView *mapImageView;
@property (weak, nonatomic) UIButton *testButton;
@property (nonatomic, strong) UIButton *buttonContainer;

@end

@implementation SAOClubMapViewController

//- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
//{
//    
//}


- (void)didTouchDownOnButton:(UIButton *)button
{
    // Highlight on touch down
    NSLog(@"Button %ld", (long)button.tag);
}


-(void) handleDoubleTap: (UIGestureRecognizer *) gestureRecognizer
{
    NSLog(@"Double tap working");

    // Passing data between views
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
    
    [self.tabBarController setSelectedIndex:2];
//    [self performSegueWithIdentifier:@"mapButtonToTableView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"mapButtonToTableView"])
    {
        NSLog(@"attempting segue");
//        TranslationQuizAssociateVC *translationQuizAssociateVC = [segue destinationViewController];
//        translationQuizAssociateVC.nodeID = self.nodeID; //--pass nodeID from ViewNodeViewController
//        translationQuizAssociateVC.contentID = self.contentID;
//        translationQuizAssociateVC.index = self.index;
//        translationQuizAssociateVC.content = self.content;
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//request for the map from online
	[self requestNewMap];
    NSLog(@"when does this occur?");
    [self.mapScrollView bringSubviewToFront:self.testButton];
    NSLog(@"button briefly to front");
	
}

-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

/*
//////Helper Methods//////
-(NSMutableArray *) locations {
    
    // Json Data
    if (!_locations) {
        NSData* locationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.dataFileName ofType:@"json"]];
        
        NSError *error;
        NSArray *tempLocation;
        tempLocation = [NSJSONSerialization JSONObjectWithData:locationData options:0 error:&error];
        int i = 0;
        NSMutableArray *mutableLocation = [tempLocation mutableCopy];
        for (NSDictionary *dict in tempLocation) {
            NSMutableDictionary *mutableDictionary = [dict mutableCopy];
            [mutableDictionary setObject:<#(id)#> forKey:<#(id<NSCopying>)#>];
            mutableLocation[i] = mutableDictionary;
            i++;
        }
        _locations = [mutableLocation copy];
        if (error) NSLog(@"JSON error: %@", error);
    }
    return _locations;
}

-(NSString *) getCategoryKey {
    // Loops through NSArray locations to find if tapped CGPoint is within which category
    //
    NSString *category;
    for (NSDictionary *locationDict in self.locations) {
        
        if ([locationDict[] isEqualToString: ) {
            category = [];
        }
    }
    
}

             

-(float) distanceBetweenPoints:(CGPoint) touched and: (CGPoint) data {
     return sqrtf(powf((touched.x - data.x), 2) + powf((touched.y - data.y), 2));
 }


-(CGPoint) getCategoryLocation:(CGPoint) touched {
    CGPoint point;
    float min = INFINITY;
    float distance;
    for (NSDictionary *locationDict in self.locations) {
        CGPoint data = CGPointMake([locationDict[@"x"] floatValue], [locationDict[@"y"] floatValue]);
        distance = [self distanceBetweenPoints:touched and: data];
        if (distance < min) {
            min = distance;
            point = data;
        }
    }
    return point;
}

-(BOOL) isClubHere:(CGPoint) touched
{
    BOOL pointIsHere;
    float min = INFINITY;
    float distance;
    for(NSDictionary *locationDict in self.locations) {
        CGPoint data = CGPointMake([locationDict[@"x"] floatValue], [locationDict[@"y"] floatValue]);
        distance = [self distanceBetweenPoints:touched and: data];
        if (distance < min) {
            min = distance;
            if (![locationDict[])
        }
    }
}

-(IBAction)doubleTap:(UITapGestureRecognizer *) sender {
    CGPoint touched = [sender locationInView:self.container];
    CGPoint scaledTouch;
    
    scaledTouch.x = (8.0/320.0)*(touched.x);
    scaledTouch.y = (8.0/320.0)*(touched.y);
    
    // 
    CGPoint point = [self getCategoryLocation:scaledTouch];
    
    // Get key from
    NSString *category = [self getCategoryKey];
    
    // Use key to segue back to corresponding category in the club list table
}
*/

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
    NSLog(@"added image again");
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

    //double scale = MAX(self.mapScrollView.frame.size.width / self.mapImage.size.width,
    //                   self.mapScrollView.frame.size.height / self.mapImage.size.height);
    
    // x, y, width, height
    CGRect Frame= CGRectMake(370, 650, 900, 100);
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    Button.frame = Frame;
	
    UIImage *Img = [UIImage imageNamed:@"FilledStar.png"];
    [Button setBackgroundImage:Img forState:UIControlStateNormal];
    
    self.testButton = Button;
//    [self.testButton addTarget:self action:@selector(didTouchDownonButton:) forControlEvents:UIControlEventTouchDown];
    [self.testButton addTarget:self action:@selector(handleDoubleTap:)     forControlEvents:UIControlEventTouchDownRepeat];
    
    [self.mapImageView addSubview: self.testButton];
    [self.mapImageView bringSubviewToFront:self.testButton];
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
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//start with a clean slate
	[(SAOTabBarController*)self.tabBarController setReceivedData: [[NSMutableData alloc] init]];
	
	//make the request in the background
	[[NSURLConnection alloc] initWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.nd.edu/~sao/SAO_App/SAO_Map.jpg"]] delegate:(SAOTabBarController*)self.tabBarController];
    NSLog(@"this is trying to dl image");
    
}

//////Finish Helper Methods//////

@end
