# HuddleKit
An iOS library for accessing the [Huddle API](http://code.google.com/p/huddle-apis/).

An example application can be found at [https://github.com/Huddle/HuddleKitExampleApp](https://github.com/Huddle/HuddleKitExampleApp).

## Getting started

### Add HuddleKit to your project

Using [CocoaPods](http://cocoapods.org) add the following line to your `Podfile`

```ruby
pod 'HuddleKit', :git => 'https://github.com/Huddle/HuddleKit.git'
````

### Add HuddleKit.h to your project's -Prefix.pch file

```objc
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "HuddleKit.h"
```

### Set your API Client Id and Redirect URL

Inside your project's `AppDelegate.m`, add the following to the end of the `application:didFinishLaunchingWithOptions:` method, replacing with the values obtained after [registering for an API key](https://login.huddle.net/docs/index.html):

```objc
[HuddleKit setClientId:@"YOUR_API_CLIENT_ID"];
[HuddleKit setRedirectUrl:@"YOUR_API_REDIRECT_URL"]; // e.g. my-huddlekit-app://auth-callback/
````

### Set the app to response to your API redirect URL

1. Select the target
2. Go to the `Info` tab
3. Expand `URL Types`
4. Click `+` in the bottom left
5. Fill in `URL Schemes` with your custom scheme e.g. `my-huddlekit-app`

### Use the API

```objc
// In some UIViewController
if ([[HDKSession sharedSession] isAuthenticated]) {
    [[HDKHTTPClient sharedClient] getPath:@"/entry" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do something with the response
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // error calling the API
    }];
} else {
    HDKSignInViewController *signInViewController = [[HDKSignInViewController alloc] initWithDelegate:self];
    [self presentViewController:signInViewController animated:YES completion:nil];
}
```

