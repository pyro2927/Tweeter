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
#import "CCJSONParser.h"

#define kServiceName	@"Tweeter"
#define kLoginSuccess	@"Logged in Successfully"
#define kError			@"Tweeter Error"
#define kDictTweet		@"DictTweet"
#define kDictDate		@"DictDate"
#define kDictTime		@"DictTime"
#define kDictUser		@"DictUser"

@interface Tweeter : NSObject {
	NSString *user, *pass;
	NSUserDefaults *userDefaults;
	BOOL authenticated;
	NSDictionary *results;
}

-(id)init;
-(void)loginWithUsername:(NSString *)username password:(NSString *)password;
-(void)post:(NSString *)tweet;
-(UIImage *)getMyPic;
-(UIImage *)getProfilePic:(NSString	*)profID;
+(NSArray *)getTweets:(NSString *)profID;

@property (nonatomic, retain) NSString *user, *pass;
@property (nonatomic, retain) NSDictionary *results;

@end
