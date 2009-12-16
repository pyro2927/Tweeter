//
//  Tweeter.m
//  Tweeter
//
//  Created by Joseph Pintozzi on 9/23/09.
//  Copyleft 2009 Tiny Dragon Apps, LLC. All rights reserved.
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
-(NSDictionary *)getUserDict;
-(NSString *)getUsername;
-(void)setTweet:(NSString *)string;
-(void)setDate:(NSString *)string;
-(void)setTime:(NSString *)string;
-(void)setUser:(NSDictionary *)string;
-(void)setUser:(NSDictionary *)user andTweet:(NSString *)tweet andDate:(NSString *)date andTime:(NSString *)time;

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
-(NSDictionary *)getUserDict{
	return [self.dict objectForKey:kDictUser];
}
-(NSString *)getUsername{
	return [[self.dict objectForKey:kDictUser] objectForKey:@"screen_name"];
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
-(void)setUser:(NSDictionary *)temp{
	if (temp == nil) {
		[self.dict setObject:@"" forKey:kDictUser];
	}
	else {
		[self.dict setObject:temp forKey:kDictUser];
	}
}
-(void)setUser:(NSDictionary *)user andTweet:(NSString *)tweet andDate:(NSString *)date andTime:(NSString *)time{
	[self setUser:user];
	[self setTweet:tweet];
	[self setDate:date];
	[self setTime:time];
}
@end


@implementation Tweeter
@synthesize user, pass, results, authenticated;

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

//Checks to see if credentials have been stored before, that way we don't need to login
-(BOOL)hasCredentials{
	//setup request wtih URL
	NSURL *url = [NSURL URLWithString:@"http://twitter.com/account/verify_credentials.json"];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(authDone:)];
	[request setDidFailSelector:@selector(authFailed:)];
	
	NSString *username = [userDefaults objectForKey:kTweeterUser];
	if (!username) {
		return NO;
	}
	return YES;
}

//log out and clean up user authentication
-(void)logout{
	NSURL *url = [NSURL URLWithString:@"https://twitter.com/account/end_session.xml"];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request start];
	NSString *username = [userDefaults objectForKey:kTweeterUser];
	[userDefaults removeObjectForKey:kTweeterUser];
	NSError *error = nil;
	[SFHFKeychainUtils deleteItemForUsername:username andServiceName:kServiceName error:&error];
}

//Posts to twitter
-(void)post:(NSString *)tweet{
	//setup request wtih URL
	NSURL *url = [NSURL URLWithString:@"https://twitter.com/statuses/update.xml"];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(postDone:)];
	[request setDidFailSelector:@selector(postFailed:)];
	
	//pull username and password from keychain
	NSString *username = [userDefaults objectForKey:kTweeterUser];
	NSError *error = nil;
	NSString *dataStr = [NSString stringWithFormat:@"%@:%@", username, [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kServiceName error:&error]];
	
	if (!self.authenticated) {
		[self loginWithUsername:username password:[SFHFKeychainUtils getPasswordForUsername:username andServiceName:kServiceName error:&error]];
	}
	
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

//Get's a user's picture after authenticating
-(UIImage *)getMyPic{
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.results objectForKey:@"profile_image_url"]]]];
}

//Get a user's picture
//Returned as a UIImage
//TODO: finish
-(UIImage *)getProfilePic:(NSString	*)profID{
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@""]]];
}

//returns an array of Posts pulled from the given URL
+(NSArray *)getTweets:(NSURL *)url{
	NSLog(@"Pulling info");
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
		[post setUser: [[pulled objectAtIndex:i] objectForKey:@"user"]];
		[tweets addObject:post];
		post = nil;
	}
	NSLog(@"Posts added");
	//[post release];
	
	return tweets; //[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:url encoding:4 error:nil]];
}

//Returns array of Posts from a specific user's timeline
+(NSArray *)getUserTimeline:(NSString *)profID{
	return [self getTweets:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/statuses/user_timeline/%@.json",profID]]];
}

//Returns an array of Posts from the public timeline
+(NSArray *)getPublicTimeline{
	return [self getTweets:[NSURL URLWithString:@"https://twitter.com/statuses/public_timeline.json"]];
}

//This cannot be a '+' method because you have to authenticate before being able to use this
//Returns an array of Posts
-(NSArray *)getFriendsTimeline{
	if (self.authenticated == TRUE) {
		return [Tweeter getTweets:[NSURL URLWithString:@"https://twitter.com/statuses/friends_timeline.json"]];
	}
	else {
		return nil;
	}
}

//Search a word or a string of words
+(NSArray *)search:(NSString *)query{
	NSLog(@"Search query: %@", query);
	NSMutableString *temp = [NSMutableString stringWithString:query];
	NSRange range = NSMakeRange(0, [query length]);
	[temp replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:range];
	NSArray *array = [[NSArray alloc] initWithArray:[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@",temp]] encoding:4 error:nil]]];
	//the results are returned as an array within an array, at index 4
	NSLog(@"Array count: %d", [array count]);
	array = [array objectAtIndex:4];
	NSLog(@"%@",[array objectAtIndex:1]);
	
	NSMutableArray *tweets = [[NSMutableArray alloc] init];
	
	Post *post = [[Post alloc] init];
	
	for (int i = 0; i < [array count]; i++) {
		NSLog(@"Adding post %d",i);
		post = [[Post alloc] init];
		[post setTweet: [[array objectAtIndex:i] objectForKey:@"text"]];
		[post setDate: [[array objectAtIndex:i] objectForKey:@"created_at"]];
		[post setTime: [[array objectAtIndex:i] objectForKey:@"created_at"]];
		NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
		[d setObject:[[array objectAtIndex:i] objectForKey:@"from_user"] forKey:@"screen_name"];
		[post setUser: (NSDictionary *)d];
		[tweets addObject:post];
		NSLog(@"Post %d added",i);
		post = nil;
		[d release];
	}
	
	return array;
}
//Search a specific user's name, do NOT include "@"
//TODO: Finish this search function.  Does not work properly.
+(NSArray *)searchUser:(NSString *)query{
	NSLog(@"Searching username: %@", query);
	return [Tweeter search:[NSString stringWithFormat:@"%40%@", query]];
}

//Gather trends from feed
//Returns an array of strings showing the latest trends
//TODO: Sometimes this works, sometimes this fails.  Trying to figure out the bug
+(NSArray *)getTrends{
	NSArray *array = [[NSArray alloc] initWithArray:[CCJSONParser objectFromJSON:[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://search.twitter.com/trends.json"] encoding:4 error:nil]]];
	if (array == nil) {
		NSLog(@"nothing pulled from trends");
		return nil;
	}
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	array = [array objectAtIndex:1];
	for (int i = 0; i < [array count]; i++) {
		[temp addObject:[[array objectAtIndex:i] objectForKey:@"name"]];
	}
	return temp;
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
	NSError *error = nil;
	[SFHFKeychainUtils storeUsername:user andPassword:pass forServiceName:kServiceName updateExisting:FALSE error:&error];
	NSLog(@"Username/password stored in keychain");
	[userDefaults setObject:user forKey:kTweeterUser];
	authenticated = TRUE;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLoginSuccess object:nil]];
}
-(void)authFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kError object:nil]];
}

- (void)requestDone:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	NSLog(@"Response: %@", response);
}

-(void)postDone:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	NSLog(@"Response: %@", response);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPostSuccess object:nil]];
}

-(void)postFailed:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	NSLog(@"Response: %@", response);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPostError object:nil]];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}

@end
