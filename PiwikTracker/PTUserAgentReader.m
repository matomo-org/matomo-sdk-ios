//
//  UserAgentReader.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/14/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import "PTUserAgentReader.h"

// Private stuff
@interface PTUserAgentReader ()
@property (retain, nonatomic) UIWebView *webWiew;
@property (copy, nonatomic) void (^callbackBlock)(NSString*);
@end


// Class implementation
@implementation PTUserAgentReader


@synthesize webWiew = webView_;
@synthesize callbackBlock = callbackBlock_;


// Free memory
- (void) dealloc {
  self.webWiew = nil;
  self.callbackBlock = nil;
  [super dealloc];
}


// Get the user agent profile string
- (void)userAgentStringWithCallbackBlock:(void (^)(NSString*))block {
  
  self.callbackBlock = block;
  
  self.webWiew = [[[UIWebView alloc] init] autorelease];
  self.webWiew.delegate = self;
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];  
  [self.webWiew loadRequest:request];
}


// Webview delegate, called just before starting to load the request
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  //NSLog(@"All headers: %@", [request allHTTPHeaderFields]);
  //NSLog(@"UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);

  self.callbackBlock([request valueForHTTPHeaderField:@"User-Agent"]);
  
  return NO;
}






@end
