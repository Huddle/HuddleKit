//
//  HDKLoginHTTPClient.h
//  HuddleKit
//
//  Copyright (c) 2014 Huddle. All rights reserved.
//

#import "AFHTTPClient.h"

@interface HDKLoginHTTPClient : AFHTTPClient

+ (HDKLoginHTTPClient *)sharedClient;

+ (void)setLoginBaseUrl:(NSString *)loginBaseUrl;
+ (void)setClientId:(NSString *)clientId;
+ (void)setRedirectUrl:(NSString *)redirectUrl;
+ (NSString *)redirectUrl;

- (void)signInWithAuthorizationCode:(NSString *)code
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)refreshAccessTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (NSString *)loginPageUrl;

@end
