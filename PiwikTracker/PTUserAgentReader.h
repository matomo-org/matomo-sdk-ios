//
//  UserAgentReader.h
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/14/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTUserAgentReader : NSObject <UIWebViewDelegate>

- (void)userAgentStringWithCallbackBlock:(void (^)(NSString*))block;

@end
