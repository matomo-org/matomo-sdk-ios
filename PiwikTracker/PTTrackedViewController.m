//
//  PTTrackedViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 1/19/13.
//
//

#import "PTTrackedViewController.h"
#import "PiwikTracker.h"

// Private stuff
@interface PTTrackedViewController ()
@end


// Implementatin
@implementation PTTrackedViewController

// Send a page view when the view controller view is added to the view hierarchy
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (self.trackedViewName != nil) {
    PiwikTracker *tracker = [PiwikTracker sharedTracker];
    [tracker trackPageview:self.trackedViewName completionBlock:^(NSError *error) {
      NSLog(@"Page view tracked view controller with name:%@", self.trackedViewName);
    }];
  }
}

@end
