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
	//pic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[twit.results objectForKey:@"profile_image_url"]]]];
	pic.image = [twit getMyPic];
}
-(IBAction)post{
	//[twit post:tweetBox.text];
	if (twit != nil) {
		if (twit.authenticated == TRUE) {
			[twit post:tweetBox.text];
		}
		else {
			NSLog(@"Did not authenticate first");
		}
	}
	else {
		NSLog(@"Twit object not created");
	}

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField.tag == 1) {
		//[[[[UIApplication sharedApplication] delegate] window] makeFirstResponder:pass];
	}
	else {
		[theTextField resignFirstResponder];
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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
}


- (void)dealloc {
    [super dealloc];
}

@end
