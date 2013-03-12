//
//  PWTUserAgentReader.h
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PWTUserAgentReader : NSObject <UIWebViewDelegate>

- (void)userAgentStringWithCallbackBlock:(void (^)(NSString*))block;

@end
