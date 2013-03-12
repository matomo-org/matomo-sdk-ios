//
//  ImageViewController.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "ImageViewController.h"

#import "AppDelegate.h"

@implementation ImageViewController

@synthesize imageView = imageView_;
@synthesize navController = navController_;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                title:(NSString *)title
                image:(UIImage *)image {
  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil];
  if (self) {
    self.title = self.trackedViewName = title;
    self.imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return self;
}


- (void)dealloc {
  [imageView_ release];
  [navController_ release];
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

@end
