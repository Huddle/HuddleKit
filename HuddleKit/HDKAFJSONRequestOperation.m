//
//  HDKAFJSONRequestOperation.m
//  HuddleKit
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "HDKAFJSONRequestOperation.h"

@implementation HDKAFJSONRequestOperation

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL];
        [urlRequest setValue:[self.request valueForHTTPHeaderField:@"Authorization"] forHTTPHeaderField:@"Authorization"];
        for (NSString *header in [[request allHTTPHeaderFields] keyEnumerator]) {
            [urlRequest setValue:[request valueForHTTPHeaderField:header] forHTTPHeaderField:header];
        }

        return urlRequest;
    } else {
        return request;
    }
}

@end
