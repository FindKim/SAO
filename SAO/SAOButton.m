//
//  SAOButton.m
//  SAO
//
//  Created by Sean Fitzgerald on 8/14/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOButton.h"
#import <QuartzCore/QuartzCore.h>

#define BUTTON_BORDER_DARKNESS 0.5
#define BUTTON_BORDER_THICKNESS 2
#define BUTTON_CORNER_RADIUS 4

@implementation SAOButton

-(id) init
{
	self = [super init];
	if (self) {
		[self setupBorder];
		self.imageView.contentMode = UIViewContentModeScaleToFill;
		[self setTitleColor:[super titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
		[self setupView];
	}
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupBorder];
		self.imageView.contentMode = UIViewContentModeScaleToFill;
		[self setTitleColor:[super titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
		[self setupView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setupBorder];
		self.imageView.contentMode = UIViewContentModeScaleToFill;
		[self setTitleColor:[super titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
		[self setupView];
	}
	return self;
}

- (void)awakeFromNib
{
	[self setupView];
}

-(void) setupBorder
{
	
	const CGFloat* components = CGColorGetComponents(self.backgroundColor.CGColor);
	if (components)
		self.layer.borderColor = [[[UIColor alloc] initWithRed:components[0] * BUTTON_BORDER_DARKNESS
																										 green:components[1] * BUTTON_BORDER_DARKNESS
																											blue:components[2] * BUTTON_BORDER_DARKNESS
																										 alpha:CGColorGetAlpha(self.backgroundColor.CGColor)] CGColor];
	self.layer.borderWidth = BUTTON_BORDER_THICKNESS;
	//self.clipsToBounds = YES;
	[self.layer setCornerRadius:BUTTON_CORNER_RADIUS];
	
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	[self setupBorder];
}

-(void)setHighlighted:(BOOL)highlighted
{
	
	if (highlighted == YES)
	{
		[self highlightView];
	} else
	{
		[self clearHighlightView];
	}
	
	[super setHighlighted:highlighted];
}

- (void)setupView
{
	[self setupBorder];
	self.clipsToBounds = YES;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	[self clearHighlightView];
}

- (void)highlightView
{
	self.layer.backgroundColor = [UIColor colorWithRed:222.0/255 green:164.0/255 blue:0.0/255 alpha:1.0].CGColor;
}

- (void)clearHighlightView {
	self.layer.backgroundColor = [UIColor colorWithRed:242.0/255 green:184.0/255 blue:6.0/255 alpha:1.0].CGColor;
}



@end
