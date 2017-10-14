@import PiwikTracker;

#import "ObjectiveCCompatibilityChecker.h"

@implementation ObjectiveCCompatibilityChecker

- (void)check {
    [PiwikTracker configureSharedInstanceWithSiteID:@"5" baseURL:[NSURL URLWithString:@"http://example.com/piwik.php"] userAgent:nil];
    [[PiwikTracker shared] trackWithView:@[@"example"] url:nil];
    [[PiwikTracker shared] trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil];
    [[PiwikTracker shared] dispatch];
    [PiwikTracker shared].logger = [[DefaultLogger alloc] initWithMinLevel:LogLevelVerbose];
}

@end
