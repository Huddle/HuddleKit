//
//  HuddleKit.h
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKHTTPClient.h"
#import "HDKSession.h"
#import "HDKSignInViewController.h"
#import <Foundation/Foundation.h>

@interface HuddleKit : NSObject

+ (void)setClientId:(NSString *)clientId;
+ (void)setRedirectUrl:(NSString *)redirectUrl;

@end
