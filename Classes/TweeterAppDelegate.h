//
//  TweeterAppDelegate.h
//  Tweeter
//
//  Created by Joseph Pintozzi on 11/10/09.
//  Copyright Tiny Dragon Apps LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweeterViewController;

@interface TweeterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TweeterViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TweeterViewController *viewController;

@end

