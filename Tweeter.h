//
//  Tweeter.h
//  Jamaica2Go
//
//  Created by Joseph Pintozzi on 9/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "SFHFKeychainUtils.h"

@interface Tweeter : NSObject {
	NSString *user, *pass;
	NSUserDefaults *userDefaults;
	BOOL authenticated;
}

-(BOOL)validUsername:(NSString *)username password:(NSString *)password;
-(BOOL)post:(NSString *)tweet;

@property (nonatomic, retain) NSString *user, *pass;

@end
