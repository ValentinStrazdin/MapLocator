//
//  ViewController.m
//  MapLocator
//
//  Created by Valentin Strazdin on 7/25/14.
//  Copyright (c) 2014 Valentin Strazdin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *myLocationManager;
@property BOOL displayPasteboardError;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.displayPasteboardError = YES;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(processPasteBoard)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(appWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"Frame - %@", NSStringFromCGRect(self.view.frame));
    
    if (!self.myLocationManager) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.myLocationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager locationServicesEnabled]) {
        self.map.showsUserLocation = YES;
        [self processPasteBoard];
    }
}

- (void)appWillResignActive:(NSNotification *)notification {
    // Here we dismiss alert view
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        self.map.showsUserLocation = YES;
        [self processPasteBoard];
    }
}

- (void)processPasteBoard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *message = [pasteboard string];
    NSRange range = [message rangeOfString:@"N "];
    if (range.location == NSNotFound) {
        [self pasteBoardError];
        return;
    }
    message = [message substringFromIndex:NSMaxRange(range)];
    range = [message rangeOfString:@"E "];
    if (range.location == NSNotFound) {
        [self pasteBoardError];
        return;
    }
    CLLocationDegrees latitude = [[[message substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] doubleValue];
    message = [message substringFromIndex:NSMaxRange(range)];
    range = [message rangeOfString:@" "];
    if (range.location == NSNotFound) {
        [self pasteBoardError];
        return;
    }
    CLLocationDegrees longitude = [[[message substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] doubleValue];
    
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(latitude, longitude);
    region.span = MKCoordinateSpanMake(0.02, 0.02);
    
    self.map.region = region;
    
    // Place a single pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = region.center;
    annotation.title = @"Машина"; //You can set the subtitle too
    [self removeAllAnnotations];
    [self.map addAnnotation:annotation];
}

- (void)pasteBoardError {
    if (self.displayPasteboardError) {
        self.displayPasteboardError = NO;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error"
                                                                    message:@"Clipboard data has incorrect format"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)removeAllAnnotations {
    NSInteger toRemoveCount = self.map.annotations.count;
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:toRemoveCount];
    for (id annotation in self.map.annotations)
        if (annotation != self.map.userLocation)
            [toRemove addObject:annotation];
    [self.map removeAnnotations:toRemove];
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    
}

@end
