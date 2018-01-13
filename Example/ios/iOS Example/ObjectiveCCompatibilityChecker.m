@import MatomoTracker;

#import "ObjectiveCCompatibilityChecker.h"

@implementation ObjectiveCCompatibilityChecker

- (void)check {
    [MatomoTracker configureSharedInstanceWithSiteID:@"5" baseURL:[NSURL URLWithString:@"http://example.com/piwik.php"] userAgent:nil];
    [[MatomoTracker shared] trackWithView:@[@"example"] url:nil];
    [[MatomoTracker shared] trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil url:nil];
    [[MatomoTracker shared] dispatch];
    [MatomoTracker shared].logger = [[DefaultLogger alloc] initWithMinLevel:LogLevelVerbose];
}

- (void)checkDeprecated {
    [[MatomoTracker shared] trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil];
}

@end
