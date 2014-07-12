//
//  SAOTabBarController.h
//  SAO
//
//  Created by Sean Fitzgerald on 8/14/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSVParser.h"

@interface SAOTabBarController : UITabBarController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, CSVParserDelegate>

@property (strong, nonatomic) NSMutableArray * clubs;
@property (nonatomic, strong) NSArray * clubCategories;
@property (strong, nonatomic) NSMutableArray * clubKeys;
@property (nonatomic, strong) NSMutableData * receivedData;
@property (nonatomic, strong) CSVParser * parser;

@end
