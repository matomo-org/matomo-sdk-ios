@import MatomoTracker;

#import "ObjectiveCCompatibilityChecker.h"

@implementation ObjectiveCCompatibilityChecker

- (void)check {
    MatomoTracker *matomoTracker = [[MatomoTracker alloc] initWithSiteId:@"5" baseURL:[NSURL URLWithString:@"http://example.com/piwik.php"] userAgent:nil];
    [matomoTracker trackWithView:@[@"example"] url:nil];
    [matomoTracker trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil url:nil];
    [matomoTracker trackSearchWithQuery:@"custom search string" category:@"custom search category" resultCount:15 url:nil];
    [matomoTracker dispatch];
    matomoTracker.logger = [[DefaultLogger alloc] initWithMinLevel:LogLevelVerbose];
    matomoTracker.visitorId = @"Just a custom id";
}

- (void)checkDeprecated {
    MatomoTracker *matomoTracker = [[MatomoTracker alloc] initWithSiteId:@"5" baseURL:[NSURL URLWithString:@"http://example.com/piwik.php"] userAgent:nil];
    [matomoTracker trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil];
}

@end
