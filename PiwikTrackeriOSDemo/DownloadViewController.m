//
//  DownloadViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 22/05/15.
//  Copyright (c) 2015 Mattias Levin. All rights reserved.
//

#import "DownloadViewController.h"
@import PiwikTrackerSwift;

@implementation DownloadViewController

- (IBAction)downloadAction:(id)sender {
    [[PiwikTracker sharedInstance] sendDownloadWithUrl:@"http://dn.se/some/content/image.png"];
}

@end
