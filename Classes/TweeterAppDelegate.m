//
//  TweeterAppDelegate.m
//  Tweeter
//
//  Created by Joseph Pintozzi on 11/10/09.
//  Copyright Tiny Dragon Apps LLC 2009. All rights reserved.
//

#import "TweeterAppDelegate.h"
#import "TweeterViewController.h"

@implementation TweeterAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
