//
//  SearchViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 10/6/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "SearchViewController.h"
@import PiwikTrackerSwift;

@interface SearchViewController ()
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PiwikTracker sharedInstance] sendViews:@[@"menu", @"search"]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search for : %@", searchBar.text);
    
    // Send the search keyword and the number of found results to Piwik
    [[PiwikTracker sharedInstance] sendSearchWithKeyword:searchBar.text category:@"PiwikSearch" hitcount:arc4random_uniform(100)];
}

@end
