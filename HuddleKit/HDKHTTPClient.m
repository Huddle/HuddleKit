//
//  HDKHTTPClient.m
//  HuddleKit
//
//  Copyright (c) 2015 Huddle. All rights reserved.
//

#import "HDKHTTPClient.h"
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
        self.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:_clientId forHTTPHeaderField:@"X-Client-App"];

        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/vnd.huddle.data.v2+json", nil];
        AFHTTPResponseSerializer *httpResponseSerializer = [[AFHTTPResponseSerializer alloc] init];
        self.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonResponseSerializer, httpResponseSerializer]];

        [self setAuthorizationHeaderWithToken:[[HDKSession sharedSession] accessToken]];
        __weak HDKHTTPClient *weakSelf = self;
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
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
    NSURLRequest * (^redirectResponse)(NSURLConnection *, NSURLRequest *, NSURLResponse *) = ^(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        if (redirectResponse) {
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL];
            [urlRequest setValue:[connection.originalRequest valueForHTTPHeaderField:@"Authorization"] forHTTPHeaderField:@"Authorization"];
            for (NSString *header in [[connection.originalRequest allHTTPHeaderFields] keyEnumerator]) {
                [urlRequest setValue:[connection.originalRequest valueForHTTPHeaderField:header] forHTTPHeaderField:header];
            }

            return (NSURLRequest *)urlRequest;
        } else {
            return request;
        }
    };

    void (^refreshTokenFailure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        BOOL isAnApiV1AuthenticationError = [self isAnApiV1AuthenticationError:operation];
        NSString *authFailHeader = [[operation response] allHeaderFields][@"Www-Authenticate"];
        if ((authFailHeader && [authFailHeader rangeOfString:@"invalid_token"].location != NSNotFound) || isAnApiV1AuthenticationError) {
            [self refreshAccessTokenWithSuccess:^(AFHTTPRequestOperation *refreshOperation, id responseObject) {
                NSMutableURLRequest *mutableUrlRequest = (NSMutableURLRequest *)urlRequest;
                NSString *authorizationHeader = [self.requestSerializer valueForHTTPHeaderField:@"Authorization"];
                [mutableUrlRequest setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
                AFHTTPRequestOperation *httpRequestOperation = [super HTTPRequestOperationWithRequest:mutableUrlRequest success:success failure:failure];
                NSString *acceptHeader = [urlRequest valueForHTTPHeaderField:@"Accept"];
                [httpRequestOperation setRedirectResponseBlock:redirectResponse];

                if (filePath) {
                    httpRequestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                }
                [self.operationQueue addOperation:httpRequestOperation];
            } failure:failure];
        } else {
            if (failure) {
                failure(operation, error);
            }
        }
    };

    AFHTTPRequestOperation *httpRequestOperation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:refreshTokenFailure];
    NSString *acceptHeader = [urlRequest valueForHTTPHeaderField:@"Accept"];
    [httpRequestOperation setRedirectResponseBlock:redirectResponse];

    return httpRequestOperation;
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
    [self.requestSerializer setValue:[NSString stringWithFormat:@"OAuth2 %@", token] forHTTPHeaderField:@"Authorization"];
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
    id responseJSON = [operation responseObject];
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
