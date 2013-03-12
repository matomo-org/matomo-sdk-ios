//
//  ViewController.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "CategoryViewController.h"
#import "ImageViewController.h"

#import "GAI.h"

@interface CategoryViewController ()

@property(nonatomic, retain) NSMutableArray *items;
@property(nonatomic, assign) AppDelegate *delegate;

@end

@implementation CategoryViewController

@synthesize category = category_;
@synthesize navController = navController_;
@synthesize tableView = tableView_;
@synthesize items = items_;
@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibName
               bundle:(NSBundle *)nibBundle
             category:(NSString *)category {
  self = [super initWithNibName:nibName
                         bundle:nibBundle];
  if (self) {
    self.category = category;
    self.trackedViewName = category;
    self.title = [NSString stringWithFormat:@"Cute %@s", category];
    self.delegate = [UIApplication sharedApplication].delegate;
  }
  return self;
}

- (void)dealloc {
  [category_ release];
  [navController_ release];
  [tableView_ release];
  [items_ release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.items = [self.delegate.images objectForKey:self.category];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] ==
      UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  if (indexPath.row < 0 || indexPath.row >= self.items.count) {
    NSLog(@"IndexPath %d out of bounds!", indexPath.row);
    return;
  }
  NSString *title =
      [NSString stringWithFormat:@"%@ %d", self.category, indexPath.row];
  UIImage *image = [self.items objectAtIndex:indexPath.row];
  ImageViewController *imageViewController =
      [[[ImageViewController alloc] initWithNibName:nil
                                             bundle:nil
                                              title:title
                                              image:image] autorelease];
  [imageViewController.view addSubview:imageViewController.imageView];
  [self.navController pushViewController:imageViewController animated:YES];
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

  static NSString *CellId = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:CellId] autorelease];
  }

  cell.textLabel.text = [NSString stringWithFormat:@"%@ %d",
                         self.category, indexPath.row];
  cell.textLabel.font = [UIFont systemFontOfSize:14];
  UIImage *image = [self.items objectAtIndex:indexPath.row];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%d x %d",
                               (int)image.size.width, (int)image.size.height];
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
  return cell;
}

@end
