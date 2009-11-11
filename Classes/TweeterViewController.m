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
	if (twit == nil) {
		twit = [[Tweeter alloc] init];
	}
	NSArray *temp = [[NSArray alloc] initWithArray:[Tweeter getTweets:@"17888112"]];
	for (int i = 0; i < [temp count]; i++) {
		NSLog(@"%@: %@", [[temp objectAtIndex:i] getUser], [[temp objectAtIndex:i] getTweet]);
	}
	//NSLog(@"%@",[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://twitter.com/statuses/user_timeline/17888112.json"] encoding:4 error:nil]]);
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
