//
//  HDKKeychainWrapper.h
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDKKeychainWrapper : NSObject

+ (NSString *)accessToken;
+ (NSString *)refreshToken;
+ (void)setAccessToken:(NSString *)accessToken;
+ (void)setRefreshToken:(NSString *)refreshToken;
+ (void)setKeychainAccessGroup:(NSString *)accessGroup;
+ (void)reset;
+ (NSString *)stringForKey:(NSString *)key;
+ (void)setString:(NSString *)value forKey:(NSString *)key;

@end
