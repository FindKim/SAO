//
//  SAOTabBarController.m
//  SAO
//
//  Created by Sean Fitzgerald on 8/14/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOTabBarController.h"
#import "SAOClubMapViewController.h"
#import "SAOClubTableViewController.h"

@interface SAOTabBarController ()

@property (nonatomic, strong) NSMutableArray * tempClubs;
@property (nonatomic, strong) NSMutableArray * tempClubKeys;

@end

@implementation SAOTabBarController

/************* PARSER DELEGATE METHODS *************/
-(void)parserLoaded:(CSVParser *) parser
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	self.tempClubs = [[NSMutableArray alloc] init];
	self.tempClubKeys = [[NSMutableArray alloc] init];
	[parser parse];
}

//parser read and recognized a value of a table and column
-(void)parser:(CSVParser *)parser
DidParseString:(NSString *) string
withRowNumber:(int)rowNumber
withColumNumber:(int)columnNumber
{
//	NSLog(@"Parsed Value (row = %d, column = %d): %@", rowNumber, columnNumber, string);
	if (rowNumber == 0)
	{
		[self.tempClubKeys addObject:string];
	} else {
		if (columnNumber == 0) [self.tempClubs addObject:[[NSMutableDictionary alloc] init]];
		[(NSMutableDictionary*)self.tempClubs[rowNumber-1] setValue:string
																										 forKey:self.tempClubKeys[columnNumber]];
	}
//#warning if the parser pulls the wrong thing from the URL (eg- boingo hotspot), then it's not a csv and there are some out of bounds exceptions here.
}

//the parser is finished reading the table
-(void)parserDidFinishParsingFile:(CSVParser *)parser
{
	dispatch_async(dispatch_get_main_queue(), ^(void){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		self.clubs = self.tempClubs;
		self.clubKeys = self.tempClubKeys;
		[[(UITableViewController*)self.viewControllers[2] tableView] reloadData];
		});
	NSLog(@"Finished parsing file.");
}

/************* END PARSER DELEGATE METHODS *************/

//////NSURLConnection delegate and dataDelegate methods//////

- ( void )connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
	// receivedData is an NSMutableData object
	[self.receivedData appendData: data ];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
	NSLog(@"received response via nsurlconnection");
}

- ( void )connectionDidFinishLoading: (NSURLConnection *)connection
{
	[(SAOClubMapViewController*)self.viewControllers[3] setMapImage: [UIImage imageWithData:self.receivedData]];
	
	[(SAOClubMapViewController*)self.viewControllers[3] resetMapScrollViewWithNewImage];
	
	NSLog(@"finished loading nsurlconnection");
}

//////Finish NSURLConnection delegate and dataDelegate methods//////

@end
