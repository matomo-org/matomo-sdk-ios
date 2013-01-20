//
//  PTTrackedViewController.h
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 1/19/13.
//
//


/**
 To automatically measure views in your app, have your view controllers extend GAITrackedViewController, 
 a convenience class that extends UIViewController, and provide the view name to give to each view 
 controller in your reports. Each time that view is loaded, a pageview will be sent.
 */
@interface PTTrackedViewController : UIViewController

/**
 The page name that will be used in the page tracking.
 Subclasses should always set this value.
 */
@property (nonatomic, strong) NSString *trackedViewName;

@end
