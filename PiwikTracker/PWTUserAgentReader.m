//
//  PWTUserAgentReader.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import "PWTUserAgentReader.h"

// Private stuff
@interface PWTUserAgentReader ()

@property (nonatomic, strong) UIWebView *webWiew;
@property (nonatomic, copy) void (^callbackBlock)(NSString*);

@end


// Class implementation
@implementation PWTUserAgentReader


// Get the user agent profile string
- (void)userAgentStringWithCallbackBlock:(void (^)(NSString*))block {
  // Must run on main thread or will throw exception
  dispatch_async(dispatch_get_main_queue(), ^{
    self.callbackBlock = block;
    
    self.webWiew = [[UIWebView alloc] init];
    self.webWiew.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [self.webWiew loadRequest:request];
  });
}


// Webview delegate, called just before starting to load the request
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  //NSLog(@"All headers: %@", [request allHTTPHeaderFields]);
  NSLog(@"UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);

  self.callbackBlock([request valueForHTTPHeaderField:@"User-Agent"]);
  
  return NO;
}






@end
