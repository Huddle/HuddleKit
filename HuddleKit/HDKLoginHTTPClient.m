//
//  HDKLoginHTTPClient.m
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKLoginHTTPClient.h"
#import "HDKAFJSONRequestOperation.h"
#import "HDKSession.h"

static NSString *_loginBaseUrl = @"https://login.huddle.net";
static NSString *_clientId;
static NSString *_redirectUrl;

@implementation HDKLoginHTTPClient

+ (HDKLoginHTTPClient *)sharedClient
{
    static HDKLoginHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HDKLoginHTTPClient alloc] init];
    });

    return _sharedClient;
}

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:_loginBaseUrl]];
    if (self != nil) {
        [self registerHTTPOperationClass:[HDKAFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        [self setDefaultHeader:@"X-Client-App" value:_clientId];
        __weak HDKLoginHTTPClient *weakSelf = self;
        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakSelf.operationQueue.suspended = (status == AFNetworkReachabilityStatusNotReachable) || (status == AFNetworkReachabilityStatusUnknown);
        }];
    }

    return self;
}

#pragma mark - Class methods

+ (void)setLoginBaseUrl:(NSString *)loginBaseUrl
{
    _loginBaseUrl = loginBaseUrl;
}

+ (void)setClientId:(NSString *)clientId
{
    _clientId = clientId;
}

+ (void)setRedirectUrl:(NSString *)redirectUrl
{
    _redirectUrl = redirectUrl;
}

+ (NSString *)redirectUrl
{
    return _redirectUrl;
}

#pragma mark - Instance methods

- (NSString *)loginPageUrl
{
    return [NSString stringWithFormat:@"%@/request?response_type=code&client_id=%@&redirect_uri=%@", _loginBaseUrl, _clientId,  _redirectUrl];
}

- (void)signInWithAuthorizationCode:(NSString *)code
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @
    {
        @"grant_type" : @"authorization_code",
        @"client_id" : _clientId,
        @"redirect_uri" : _redirectUrl,
        @"code" : code
    };

    [self postTokenWithParameters:parameters success:success failure:failure];
}

- (void)refreshAccessTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @
    {
        @"grant_type" : @"refresh_token",
        @"client_id" : _clientId,
        @"refresh_token" : [HDKSession sharedSession].refreshToken ? : @""
    };

    [self postTokenWithParameters:parameters success:success failure:failure];
}

#pragma mark - Private methods

- (void)postTokenWithParameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self postPath:@"/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *accessToken = responseObject[@"access_token"];
        NSString *refreshToken = responseObject[@"refresh_token"];

        HDKSession *session = [HDKSession sharedSession];
        session.accessToken = accessToken;
        session.refreshToken = refreshToken;

        if (success) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

@end
