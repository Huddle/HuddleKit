//
//  HDKHTTPClient.h
//  HuddleKit
//
//  Copyright (c) 2014 Huddle. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString *const HDKUserAccessGrantRevokedNotification;
extern NSString *const HDKInvalidRefreshTokenNotification;

@interface HDKHTTPClient : AFHTTPClient

+ (HDKHTTPClient *)sharedClient;

+ (void)setApiBaseUrl:(NSString *)apiBaseUrl;
+ (void)setClientId:(NSString *)clientId;

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                   filePath:(NSString *)filePath
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)refreshAccessTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
