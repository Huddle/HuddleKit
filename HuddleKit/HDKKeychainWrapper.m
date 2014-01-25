//
//  HDKKeychainWrapper.m
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKKeychainWrapper.h"

NSString *const kHDKKeychainAccessTokenKey = @"AccessToken";
NSString *const kHDKKeychainRefreshTokenKey = @"RefreshToken";
NSString *const kHDKKeychainService = @"net.huddle.HuddleKit";
static NSString *_accessGroup;

@implementation HDKKeychainWrapper

#pragma mark - Class methods

+ (NSString *)accessToken {
    return [self stringForKey:kHDKKeychainAccessTokenKey];
}

+ (void)setAccessToken:(NSString *)accessToken {
    [self setString:accessToken forKey:kHDKKeychainAccessTokenKey];
}

+ (NSString *)refreshToken {
    return [self stringForKey:kHDKKeychainRefreshTokenKey];
}

+ (void)setRefreshToken:(NSString *)refreshToken {
    [self setString:refreshToken forKey:kHDKKeychainRefreshTokenKey];
}

+ (void)setKeychainAccessGroup:(NSString *)accessGroup; {
    _accessGroup = accessGroup;
}

+ (void)reset {
    [self removeItemForKey:kHDKKeychainAccessTokenKey service:kHDKKeychainService accessGroup:_accessGroup];
    [self removeItemForKey:kHDKKeychainRefreshTokenKey service:kHDKKeychainService accessGroup:_accessGroup];
}

+ (NSString *)stringForKey:(NSString *)key {
    NSData *data = [self dataForKey:key service:kHDKKeychainService accessGroup:_accessGroup];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

+ (void)setString:(NSString *)value forKey:(NSString *)key {
    if (!value) {
        [self removeItemForKey:key service:kHDKKeychainService accessGroup:_accessGroup];
        return;
    }

    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data forKey:key service:kHDKKeychainService accessGroup:_accessGroup];
}

#pragma mark - Private class methods

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    if (!key) {
        return nil;
    }

    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecAttrService] = service;
    query[(__bridge id)kSecAttrGeneric] = key;
    query[(__bridge id)kSecAttrAccount] = key;
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif

    CFTypeRef data = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    if (status != errSecSuccess) {
        return nil;
    }

    return (__bridge_transfer NSData *)data;
}

+ (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    if (!key) {
        return;
    }

    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = service;
    query[(__bridge id)kSecAttrGeneric] = key;
    query[(__bridge id)kSecAttrAccount] = key;
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        if (data) {
            NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
            attributesToUpdate[(__bridge id)kSecValueData] = data;

            SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
        } else {
            [self removeItemForKey:key service:service accessGroup:accessGroup];
        }
    } else if (status == errSecItemNotFound) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
        attributes[(__bridge id)kSecAttrService] = service;
        attributes[(__bridge id)kSecAttrGeneric] = key;
        attributes[(__bridge id)kSecAttrAccount] = key;
        attributes[(__bridge id)kSecValueData] = data;
#if !TARGET_IPHONE_SIMULATOR
        if (accessGroup) {
            [attributes setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif

        SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
    }
}

+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    if (!key) {
        return NO;
    }

    NSMutableDictionary *itemToDelete = [NSMutableDictionary dictionary];
    itemToDelete[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    itemToDelete[(__bridge id)kSecAttrService] = service;
    itemToDelete[(__bridge id)kSecAttrGeneric] = key;
    itemToDelete[(__bridge id)kSecAttrAccount] = key;
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup) {
        [itemToDelete setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
    return (status != errSecSuccess && status != errSecItemNotFound);
}

@end
