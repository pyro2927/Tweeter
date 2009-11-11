//
//  Tweeter.m
//  Jamaica2Go
//
//  Created by Joseph Pintozzi on 9/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tweeter.h"

@interface Post : NSObject
{
	NSMutableDictionary *dict;
}

@property (nonatomic, retain) NSMutableDictionary *dict;

-(id)init;
-(NSString *)getTweet;
-(NSString *)getDate;
-(NSString *)getTime;
-(NSString *)getUser;
-(void)setTweet:(NSString *)string;
-(void)setDate:(NSString *)string;
-(void)setTime:(NSString *)string;
-(void)setUser:(NSString *)string;

@end

@implementation Post
@synthesize dict;

-(id)init{
	dict = [[NSMutableDictionary alloc] init];
	return self;
}
-(NSString *)getTweet{
	return [self.dict objectForKey:kDictTweet];
}
-(NSString *)getDate{
	return [self.dict objectForKey:kDictDate];
}
-(NSString *)getTime{
	return [self.dict objectForKey:kDictTime];
}
-(NSString *)getUser{
	return [self.dict objectForKey:kDictUser];
}

-(void)setTweet:(NSString *)string{
	if (string == nil) {
		[self.dict setObject:@"" forKey:kDictTime];
	}
	else {
		[self.dict setObject:string forKey:kDictTweet];
	}
}
-(void)setDate:(NSString *)string{
	if (string == nil) {
		[self.dict setObject:@"" forKey:kDictTime];
	}
	else {
		[self.dict setObject:string forKey:kDictDate];
	}
}
-(void)setTime:(NSString *)string{
	if (string == nil) {
		[self.dict setObject:@"" forKey:kDictTime];
	}
	else {
		[self.dict setObject:string forKey:kDictTime];
	}
}
-(void)setUser:(NSString *)string{
	if (string == nil) {
		[self.dict setObject:@"" forKey:kDictUser];
	}
	else {
		[self.dict setObject:string forKey:kDictUser];
	}
}
@end


@implementation Tweeter
@synthesize user, pass, results;

-(id) init{
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	authenticated = FALSE;
	self.results = [[NSDictionary alloc] init];
	return self;
}

//Validates username and password
//Returns TRUE if valid, else FALSE
-(void)loginWithUsername:(NSString *)username password:(NSString *)password{
	//setup request wtih URL
	NSURL *url = [NSURL URLWithString:@"http://twitter.com/account/verify_credentials.json"];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(authDone:)];
	[request setDidFailSelector:@selector(authFailed:)];
	
	//TODO, on good authentication, store username and password into keychain
	user = username;
	pass = password;
	NSString *dataStr = [NSString stringWithFormat:@"%@:%@", user, pass];
	
	//encode
	NSData *encodeData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	
	//set memory size
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	dataStr = [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
	NSString *authenticationString = [@"" stringByAppendingFormat:@"Basic %@", dataStr];

	//Add authentication header to request
	[request addRequestHeader:@"Authorization" value:authenticationString];
	[request start];
}

//Posts to twitter
-(void)post:(NSString *)tweet{
	//setup request wtih URL
	NSURL *url = [NSURL URLWithString:@"https://twitter.com/statuses/update.xml"];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	
	//TODO: pull username and password from keychain
	NSString *username = [userDefaults objectForKey:@"username"];
	NSString *dataStr = [NSString stringWithFormat:@"%@:%@", username, [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kServiceName error:[NSError alloc]]];
	
	//encode
	NSData *encodeData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	//set memory size
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	
	dataStr = [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
	NSString *authenticationString = [@"" stringByAppendingFormat:@"Basic %@", dataStr];
	//Add authentication header to request
	
	[request addRequestHeader:@"Authorization" value:authenticationString];
	//Add POST data
	[request setPostValue:tweet forKey:@"status"];
	[request start];
}

-(UIImage *)getMyPic{
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.results objectForKey:@"profile_image_url"]]]];
}

-(UIImage *)getProfilePic:(NSString	*)profID{
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@""]]];
}

//returns an array of tweets
+(NSArray *)getTweets:(NSString *)profID{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/statuses/user_timeline/%@.json",profID]];
	NSLog(@"Pulling info");
	//NSLog(@"%@", [CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:url encoding:4 error:nil]]);
	NSMutableArray *tweets, *pulled;
	tweets = [[NSMutableArray alloc] init];
	pulled = [[NSArray alloc] initWithArray:[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:url encoding:4 error:nil]]];
	
	Post *post = [[Post alloc] init];
	
	for (int i = 0; i < [pulled count]; i++) {
		post = [[Post alloc] init];
		[post setTweet: [[pulled objectAtIndex:i] objectForKey:@"text"]];
		//TODO, parse date and time properly
		[post setDate: [[pulled objectAtIndex:i] objectForKey:@"created_at"]];
		[post setTime: [[pulled objectAtIndex:i] objectForKey:@"created_at"]];
		[post setUser: [[[pulled objectAtIndex:i] objectForKey:@"user"] objectForKey:@"screen_name"]];
		[tweets addObject:post];
		post = nil;
	}
	NSLog(@"Posts added");
	//[post release];
	
	return tweets; //[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:url encoding:4 error:nil]];
}

#pragma mark Base64 Encoding

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
    unsigned triad;
	
    for (triad = 0; triad < s_len; triad += 3)
    {
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
    }
	
    return 0;
	
}

#pragma mark Request Delegation
-(void)authDone:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	NSLog(@"Response: %@", response);
	self.results = (NSDictionary *)[CCJSONParser objectFromJSON:response];
	//Once authentication is successful, store username into keyChain
	[SFHFKeychainUtils storeUsername:user andPassword:pass forServiceName:kServiceName updateExisting:FALSE error:[NSError alloc]];
	NSLog(@"Username/password stored in keychain");
	[userDefaults setObject:user forKey:@"username"];
	authenticated = TRUE;
	//[[NSNotificationCenter defaultCenter] postNotification:kLoginSuccess];
}
-(void)authFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[alert show];
}

- (void)requestDone:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	NSLog(@"Response: %@", response);
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}

@end
