//
//  HDKSignInViewController.m
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKSignInViewController.h"
#import "HDKHTTPClient.h"
#import "HDKLoginHTTPClient.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface HDKSignInViewController () <UIWebViewDelegate>

@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) UIView *noConnectionView;

@end

@implementation HDKSignInViewController

- (id)initWithDelegate:(id <HDKSignInViewControllerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;

        NSURL *loginPageUrl = [NSURL URLWithString:[[HDKLoginHTTPClient sharedClient] loginPageUrl]];
        NSString *loginHostname = [loginPageUrl host];
        self.reachability = [Reachability reachabilityWithHostname:loginHostname];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:0.537 blue:0.816 alpha:1.0];
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    webView.hidden = YES;
    self.webView = webView;
    [self.view addSubview:webView];

    UIView *noConnectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    noConnectionView.hidden = YES;
    noConnectionView.backgroundColor = [UIColor clearColor];
    noConnectionView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    noConnectionView.center = self.view.center;
    
    UILabel *sadFaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 89, 280, 100)];
    sadFaceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sadFaceLabel.text = NSLocalizedString(@":(", nil);
    sadFaceLabel.backgroundColor = [UIColor clearColor];
    sadFaceLabel.textColor = [UIColor whiteColor];
    sadFaceLabel.textAlignment = NSTextAlignmentCenter;
    sadFaceLabel.numberOfLines = 0;
    sadFaceLabel.font = [UIFont boldSystemFontOfSize:100.0];
    sadFaceLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    sadFaceLabel.shadowOffset = CGSizeMake(0, -1);
    [noConnectionView addSubview:sadFaceLabel];

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 233, 280, 50)];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    messageLabel.text = NSLocalizedString(@"Can’t connect to Huddle", nil);
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.font = [UIFont boldSystemFontOfSize:20.0];
    messageLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    messageLabel.shadowOffset = CGSizeMake(0, -1);
    [noConnectionView addSubview:messageLabel];

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(109, 296, 20, 20)];
    [noConnectionView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    UILabel *retryingLabel = [[UILabel alloc] initWithFrame:CGRectMake(137, 291, 75, 30)];
    retryingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    retryingLabel.text = NSLocalizedString(@"Retrying…", nil);
    retryingLabel.backgroundColor = [UIColor clearColor];
    retryingLabel.textColor = [UIColor whiteColor];
    retryingLabel.textAlignment = NSTextAlignmentCenter;
    retryingLabel.numberOfLines = 0;
    retryingLabel.lineBreakMode = NSLineBreakByWordWrapping;
    retryingLabel.font = [UIFont systemFontOfSize:15.0];
    retryingLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    retryingLabel.shadowOffset = CGSizeMake(0, -1);
    [noConnectionView addSubview:retryingLabel];

    UILabel *subMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 410, 280, 30)];
    subMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    subMessageLabel.text = NSLocalizedString(@"Are you connected to the Internet?", nil);
    subMessageLabel.backgroundColor = [UIColor clearColor];
    subMessageLabel.textColor = [UIColor whiteColor];
    subMessageLabel.textAlignment = NSTextAlignmentCenter;
    subMessageLabel.numberOfLines = 0;
    subMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subMessageLabel.font = [UIFont systemFontOfSize:15.0];
    subMessageLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    subMessageLabel.shadowOffset = CGSizeMake(0, -1);
    [noConnectionView addSubview:subMessageLabel];

    self.noConnectionView = noConnectionView;
    [self.view addSubview:noConnectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [SVProgressHUD show];
    [self loadLoginPage];
    [self.reachability startNotifier];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.webView stopLoading];
    [self.reachability stopNotifier];
    [SVProgressHUD dismiss];
}

- (void)loadLoginPage
{
    if ([SVProgressHUD isVisible] == NO) {
        [SVProgressHUD show];
    }

    NSURL *url = [NSURL URLWithString:[[HDKLoginHTTPClient sharedClient] loginPageUrl]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];

    if (webView.hidden) {
        [self fadeOutView:self.noConnectionView];
        [self fadeInView:webView];
    }

    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }

    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;

    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSString *code = [url.query componentsSeparatedByString:@"="][1];
            [[HDKLoginHTTPClient sharedClient] signInWithAuthorizationCode:code success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *accessToken = responseObject[@"access_token"];
                [[HDKHTTPClient sharedClient] setAuthorizationHeaderWithToken:accessToken];
                [self.delegate signInSuccess];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.delegate signInFailure:error];
            }];
        } else {
            NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"This app can’t open url: %@", nil), url];
            NSError *error = [NSError errorWithDomain:@"net.huddle" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            [self.delegate signInFailure:error];
        }
    }

    NSString *urlString = [url description];
    if ([urlString rangeOfString:@"/grant/"].location != NSNotFound) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }

    NSURL *redirectUrl = [NSURL URLWithString:[HDKLoginHTTPClient redirectUrl]];
    if ([url.scheme isEqualToString:redirectUrl.scheme] && [url.host isEqualToString:redirectUrl.host]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == 102) { // "Frame load interrupted"
        return;
    }

    if ([error code] == -999) { // "The operation couldn’t be completed.
        return;
    }

    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark - Private methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    if (![self.reachability isReachable]) {
        [SVProgressHUD dismiss];

        [self.webView stopLoading];
        [self.webView endEditing:YES];
        [self fadeOutView:self.webView];
        [self fadeInView:self.noConnectionView];
    } else if ([self.webView isLoading]) {
        return;
    } else {
        [self loadLoginPage];
    }
}

- (void)fadeInView:(UIView *)view
{
    view.alpha = 0.0f;
    view.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^() {
        view.alpha = 1.0f;
    }];
}

- (void)fadeOutView:(UIView *)view
{
    view.alpha = 1.0f;
    [UIView animateWithDuration:0.5 animations:^() {
        view.alpha = 0.0f;
        view.hidden = YES;
    }];
}

@end
