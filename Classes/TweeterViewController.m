//
//  TweeterViewController.m
//  Tweeter
//
//  Created by Joseph Pintozzi on 11/10/09.
//  Copyright Tiny Dragon Apps LLC 2009. All rights reserved.
//

#import "TweeterViewController.h"

@implementation TweeterViewController
@synthesize name, pass, results, twit, tweetBox, pic;


-(IBAction)login{
	twit = [[Tweeter alloc] init];
	[twit loginWithUsername:name.text password:pass.text];
	NSLog(@"Attempting to pull results");
	NSLog(@"%@",twit.results);
}
-(IBAction)post{
	[twit post:tweetBox.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField.tag == 1) {
		//[[[[UIApplication sharedApplication] delegate] window] makeFirstResponder:pass];
	}
	else {
		[theTextField resignFirstResponder];
		[self login];
	}
	return YES;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(success) name:kLoginSuccess object:nil];
	 
}

-(void)success{
	results.text = @"Logged in successfully";
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
