//
//  SAOEditProfileViewController.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/27/13.
//  Copyright (c) 2013 Notre Dame. All rights reserved.
//

#import "SAOEditProfileViewController.h"

#define MAJOR (@"major")
#define NAME (@"name")
#define CLASS (@"class")
#define EMAIL (@"email")

@interface SAOEditProfileViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *classTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SAOEditProfileViewController

- (void)viewDidLoad
{
	self.nameTextField.delegate = self;
	self.majorTextField.delegate = self;
    self.classTextField.delegate = self;
	self.emailTextField.delegate = self;

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	self.nameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:NAME];
	self.majorTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:MAJOR];
    self.classTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:CLASS];
	self.emailTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL];
    NSLog(@"The class is %@",[[NSUserDefaults standardUserDefaults] valueForKey:CLASS]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];	
	return YES;
}

- (IBAction)saveBarButtonTapped:(UIBarButtonItem *)sender
{
	[[NSUserDefaults standardUserDefaults] setValue:self.nameTextField.text forKey:NAME];
	[[NSUserDefaults standardUserDefaults] setValue:self.majorTextField.text forKey:MAJOR];
    [[NSUserDefaults standardUserDefaults] setValue:self.classTextField.text forKey:CLASS];
	[[NSUserDefaults standardUserDefaults] setValue:self.emailTextField.text forKey:EMAIL];
	[self cancelBarButtonTapped:nil];
}

- (IBAction)cancelBarButtonTapped:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
