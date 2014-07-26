//
//  SAOClubNavigationController.h
//  SAO
//
//  Created by Sean Fitzgerald on 8/6/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAOClubNavigationController : UINavigationController

@property (nonatomic, strong) NSString * clubName;
@property (nonatomic, strong) NSDictionary * clubDictionary;
@property (nonatomic, strong) NSArray * clubDictionaryKeys;

@end