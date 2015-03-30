//
//  HDKHTTPClient.h
//  HuddleKit
//
//  Copyright (c) 2015 Huddle. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

extern NSString *const HDKUserAccessGrantRevokedNotification;
extern NSString *const HDKInvalidRefreshTokenNotification;

@interface HDKHTTPClient : AFHTTPRequestOperationManager

+ (HDKHTTPClient *)sharedClient;

+ (void)setApiBaseUrl:(NSString *)apiBaseUrl;
+ (void)setClientId:(NSString *)clientId;

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                   filePath:(NSString *)filePath
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)refreshAccessTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)setAuthorizationHeaderWithToken:(NSString *)token;

@end
