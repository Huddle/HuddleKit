//
//  HDKSignInViewController.h
//  HuddleKit
//
//  Copyright (c) 2014 Huddle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDKSignInViewControllerDelegate <NSObject>

- (void)signInSuccess;
- (void)signInFailure:(NSError *)error;

@optional

- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface HDKSignInViewController : UIViewController

@property (weak, nonatomic) id <HDKSignInViewControllerDelegate> delegate;
@property (strong, nonatomic) UIWebView *webView;

- (id)initWithDelegate:(id <HDKSignInViewControllerDelegate>)delegate;
- (void)loadLoginPage;

@end
