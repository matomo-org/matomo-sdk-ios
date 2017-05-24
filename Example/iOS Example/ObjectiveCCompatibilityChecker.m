@import PiwikTracker;

#import "ObjectiveCCompatibilityChecker.h"

@implementation ObjectiveCCompatibilityChecker

- (void)check {
    [Tracker configureSharedInstanceWithSiteID:@"5" baseURL:[NSURL URLWithString:@"http://example.com/piwik.php"]];
    [[Tracker shared] trackWithView:@[@"example"]];
    [[Tracker shared] trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil];
    [[Tracker shared] dispatch];
}

@end
