//
//  TweeterViewController.h
//  Tweeter
//
//  Created by Joseph Pintozzi on 11/10/09.
//  Copyright Tiny Dragon Apps LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweeter.h"

@interface TweeterViewController : UIViewController {
	IBOutlet UITextView *results;
	IBOutlet UITextField *name, *pass, *tweetBox;
	Tweeter *twit;
	IBOutlet UIImageView *pic;
}

@property (nonatomic, retain) IBOutlet UITextView *results;
@property (nonatomic, retain) IBOutlet UITextField *name, *pass, *tweetBox;
@property (nonatomic, retain) IBOutlet UIImageView *pic;
@property (nonatomic, retain) Tweeter *twit;

-(IBAction)login;
-(IBAction)post;

@end

