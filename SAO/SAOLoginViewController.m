//
//  SAOLoginViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 8/27/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOLoginViewController.h"

@interface SAOLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *netIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SAOLoginViewController


// Used to pass data between tabs
static id gGlobalInstanceTabBar = nil;
+ (UITabBarController *) tabBarController
{
    if (!gGlobalInstanceTabBar)
    {
        gGlobalInstanceTabBar = [[UITabBarController alloc] init];
    }
    return gGlobalInstanceTabBar;
}

@end
