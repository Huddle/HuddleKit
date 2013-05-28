//
//  HDKSession.m
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKSession.h"
#import "HDKHTTPClient.h"
#import "HDKKeychainWrapper.h"

@implementation HDKSession

+ (HDKSession *)sharedSession
{
    static HDKSession *_sharedSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSession = [[HDKSession alloc] init];
    });

    return _sharedSession;
}

#pragma mark - Properties

- (NSString *)accessToken
{
    return [HDKKeychainWrapper accessToken];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [HDKKeychainWrapper setAccessToken:accessToken];
}

- (NSString *)refreshToken
{
    return [HDKKeychainWrapper refreshToken];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    [HDKKeychainWrapper setRefreshToken:refreshToken];
}

#pragma mark - Instance methods

- (BOOL)isAuthenticated
{
    return self.accessToken != nil;
}

- (void)signOut
{
    [HDKKeychainWrapper reset];
    [[HDKHTTPClient sharedClient] setAuthorizationHeaderWithToken:nil];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [HDKKeychainWrapper stringForKey:key];
}

- (void)setString:(NSString *)value forKey:(NSString *)key
{
    [HDKKeychainWrapper setString:value forKey:key];
}

@end
