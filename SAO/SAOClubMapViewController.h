//
//  SAOClubMapViewController.h
//  SAO
//
//  Created by Sean Fitzgerald on 5/26/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAOClubMapViewController : UIViewController

@property (nonatomic, strong) UIImage * mapImage;

-(void)resetMapScrollViewWithNewImage;
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
@end
