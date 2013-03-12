//
//  RootViewController.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "CategoryViewController.h"
#import "ImageViewController.h"

#import "GAI.h"

@interface RootViewController ()

@property(nonatomic, retain) NSArray *items;
@property(nonatomic, assign) AppDelegate *delegate;

@end

@implementation RootViewController

@synthesize tableView = tableView_;
@synthesize navController = navController_;
@synthesize items = items_;
@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibName
               bundle:(NSBundle *)nibBundle {
  self = [super initWithNibName:nibName
                         bundle:nibBundle];
  if (self) {
    self.trackedViewName = @"root";
    self.title = @"Cute Animals";
    self.delegate = [UIApplication sharedApplication].delegate;
    [self updateSecureButton];
  }
  return self;
}

- (void)dealloc {
  [tableView_ release];
  [navController_ release];
  [items_ release];
  [super dealloc];
}

- (void)updateSecureButton {
  if ([GAI sharedInstance].defaultTracker.useHttps) {
    self.navigationItem.leftBarButtonItem.title = @"HTTPS";
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
  } else {
    self.navigationItem.leftBarButtonItem.title = @"HTTP";
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
  }
}

- (void)toggleSecure {
  [GAI sharedInstance].defaultTracker.useHttps =
      ![GAI sharedInstance].defaultTracker.useHttps;
  [self updateSecureButton];
  [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"secureDispatch"
                                                  withAction:@"toggle"
                                                   withLabel:nil
                                                   withValue:nil];
}

- (void)crash {
  [NSException raise:@"There is no spoon."
              format:@"Abort, retry, fail?"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.leftBarButtonItem =
      [[[UIBarButtonItem alloc]
        initWithTitle:@"HTTP"
                style:UIBarButtonItemStyleBordered
                target:self
                action:@selector(toggleSecure)] autorelease];
  self.navigationItem.rightBarButtonItem =
      [[[UIBarButtonItem alloc]
        initWithTitle:@"Crash"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(crash)] autorelease];
  self.items =
      [[self.delegate.images allKeys]
       sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  return NO;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  if (indexPath.row < 0 || indexPath.row >= self.items.count) {
    NSLog(@"IndexPath %d out of bounds!", indexPath.row);
    return;
  }

  NSString *category = [self.items objectAtIndex:indexPath.row];
  NSString *nib = ([[UIDevice currentDevice] userInterfaceIdiom] ==
      UIUserInterfaceIdiomPhone) ? @"CategoryViewController_iPhone" :
      @"CategoryViewController_iPad";
  CategoryViewController *categoryController =
      [[[CategoryViewController alloc] initWithNibName:nib
                                                bundle:nil
                                              category:category] autorelease];
  categoryController.navController = self.navController;
  [self.navController pushViewController:categoryController animated:YES];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < 0 || indexPath.row >= self.items.count) {
    NSLog(@"IndexPath %d out of bounds!", indexPath.row);
    return nil;
  }
  NSString *category = [self.items objectAtIndex:indexPath.row];

  static NSString *CellId = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:CellId] autorelease];
  }

  NSString *label = [NSString stringWithFormat:@"Cute %@ Pictures!", category];
  cell.textLabel.text = label;
  cell.textLabel.font = [UIFont systemFontOfSize:14];
  NSUInteger imageCount =
      [(NSArray *)[self.delegate.images objectForKey:category] count];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%u image(s).",
                               imageCount];
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
  return cell;
}

@end
