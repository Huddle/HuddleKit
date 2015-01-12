//
//  HDKHTTPClient.m
//  HuddleKit
//
//  Copyright (c) 2014 Huddle. All rights reserved.
//

#import "HDKHTTPClient.h"
#import "HDKAFJSONRequestOperation.h"
#import "HDKLoginHTTPClient.h"
#import "HDKSession.h"

static NSString *_apiBaseUrl = @"https://api.huddle.net";
static NSString *_clientId;
NSString *const HDKUserAccessGrantRevokedNotification = @"HDKUserAccessGrantRevokedNotification";
NSString *const HDKInvalidRefreshTokenNotification = @"HDKInvalidRefreshTokenNotification";

@implementation HDKHTTPClient

+ (HDKHTTPClient *)sharedClient {
    static HDKHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HDKHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_apiBaseUrl]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self != nil) {
        [self registerHTTPOperationClass:[HDKAFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        [self setDefaultHeader:@"X-Client-App" value:_clientId];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setAuthorizationHeaderWithToken:[[HDKSession sharedSession] accessToken]];
        __weak HDKHTTPClient *weakSelf = self;
        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakSelf.operationQueue.suspended = (status == AFNetworkReachabilityStatusNotReachable) || (status == AFNetworkReachabilityStatusUnknown);
        }];
    }

    return self;
}

#pragma mark - Class methods

+ (void)setApiBaseUrl:(NSString *)apiBaseUrl {
    _apiBaseUrl = apiBaseUrl;
}

+ (void)setClientId:(NSString *)clientId {
    _clientId = clientId;
}

#pragma mark - Instance methods

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self HTTPRequestOperationWithRequest:urlRequest filePath:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                   filePath:(NSString *)filePath
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    void (^refreshTokenFailure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        BOOL isAnApiV1AuthenticationError = [self isAnApiV1AuthenticationError:operation];
        NSString *authFailHeader = [[operation response] allHeaderFields][@"Www-Authenticate"];
        if ((authFailHeader && [authFailHeader rangeOfString:@"invalid_token"].location != NSNotFound) || isAnApiV1AuthenticationError) {
            [self refreshAccessTokenWithSuccess:^(AFHTTPRequestOperation *refreshOperation, id responseObject) {
                NSMutableURLRequest *mutableUrlRequest = (NSMutableURLRequest *)urlRequest;
                [mutableUrlRequest setValue:[self defaultValueForHeader:@"Authorization"] forHTTPHeaderField:@"Authorization"];
                AFHTTPRequestOperation *httpRequestOperation = [super HTTPRequestOperationWithRequest:mutableUrlRequest success:success failure:failure];
                if (filePath) {
                    httpRequestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                }
                [self enqueueHTTPRequestOperation:httpRequestOperation];
            } failure:failure];
        } else {
            if (failure) {
                failure(operation, error);
            }
        }
    };

    return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:refreshTokenFailure];
}

- (void)refreshAccessTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[HDKLoginHTTPClient sharedClient] refreshAccessTokenWithSuccess:^(AFHTTPRequestOperation *refreshOperation, id responseObject) {
        NSString *accessToken = responseObject[@"access_token"];
        [self setAuthorizationHeaderWithToken:accessToken];
        if (success) {
            success(refreshOperation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *refreshOperation, NSError *refreshError) {
        if ([self isARevokedAccessGrantError:refreshOperation]) {
            [self postUserAccessGrantRevokedNotification];
        } else if ([self isAnInvalidRefreshTokenError:refreshOperation]) {
            [self postInvalidRefreshTokenNotification];
        } else if (failure) {
            failure(refreshOperation, refreshError);
        }
    }];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth2 %@", token]];
}

#pragma mark - Private methods

- (BOOL)isAnApiV1AuthenticationError:(AFHTTPRequestOperation *)operation {
    if ([[[[operation request] URL] path] hasPrefix:@"/v1"]) {
        if ([[operation response] statusCode] == 401) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isARevokedAccessGrantError:(AFHTTPRequestOperation *)operation {
    return [self operation:operation containsError:@"RevokedAccessGrant"];
}

- (void)postUserAccessGrantRevokedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:HDKUserAccessGrantRevokedNotification object:nil];
}

- (BOOL)isAnInvalidRefreshTokenError:(AFHTTPRequestOperation *)operation {
    return [self operation:operation containsError:@"InvalidRefreshToken"];
}

- (void)postInvalidRefreshTokenNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:HDKInvalidRefreshTokenNotification object:nil];
}

- (BOOL)operation:(AFHTTPRequestOperation *)operation containsError:(NSString *)error {
    HDKAFJSONRequestOperation *jsonRequestOperation = (HDKAFJSONRequestOperation *)operation;
    id responseJSON = [jsonRequestOperation responseJSON];
    NSString *errorURI = responseJSON[@"error_uri"];

    if (errorURI) {
        NSRange range = [errorURI rangeOfString:error];
        if (range.location != NSNotFound) {
            return YES;
        }
    }

    return NO;
}

@end
