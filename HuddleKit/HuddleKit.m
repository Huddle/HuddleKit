//
//  HuddleKit.m
//  HuddleKit
//
//  Copyright (c) 2015 Huddle. All rights reserved.
//

#import "HuddleKit.h"
#import "HDKLoginHTTPClient.h"

@implementation HuddleKit

+ (void)setClientId:(NSString *)clientId {
    [HDKHTTPClient setClientId:clientId];
    [HDKLoginHTTPClient setClientId:clientId];
}

+ (void)setRedirectUrl:(NSString *)redirectUrl {
    [HDKLoginHTTPClient setRedirectUrl:redirectUrl];
}

@end
