//
//  HDKHTTPClient.h
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString *const HDKUserAccessGrantRevokedNotification;
extern NSString *const HDKInvalidRefreshTokenNotification;

@interface HDKHTTPClient : AFHTTPClient

+ (HDKHTTPClient *)sharedClient;

+ (void)setApiBaseUrl:(NSString *)apiBaseUrl;
+ (void)setClientId:(NSString *)clientId;

@end
