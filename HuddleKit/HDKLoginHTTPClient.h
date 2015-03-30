//
//  HDKLoginHTTPClient.h
//  HuddleKit
//
//  Copyright (c) 2015 Huddle. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface HDKLoginHTTPClient : AFHTTPRequestOperationManager

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
