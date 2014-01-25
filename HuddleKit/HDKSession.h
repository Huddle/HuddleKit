//
//  HDKSession.h
//  HuddleKit
//
//  Copyright (c) 2014 Huddle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDKSession : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;

+ (HDKSession *)sharedSession;

- (BOOL)isAuthenticated;
- (void)signOut;
- (NSString *)stringForKey:(NSString *)key;
- (void)setString:(NSString *)value forKey:(NSString *)key;

@end
