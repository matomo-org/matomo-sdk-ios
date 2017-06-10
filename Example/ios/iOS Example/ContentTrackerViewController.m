//
//  ContentTrackerViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 20/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "ContentTrackerViewController.h"
#import "PiwikTracker.h"


@implementation ContentTrackerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [[PiwikTracker sharedInstance] sendContentImpressionWithName:@"DN" piece:@"dn_image.png" target:@"http://dn.se"];
  
}

- (IBAction)adInteraction:(id)sender {
  
  [[PiwikTracker sharedInstance] sendContentInteractionWithName:@"DN" piece:@"dn_image.png" target:@"http://dn.se"];

  // Open link in external web browser
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.dn.se"]];
  
}


@end
