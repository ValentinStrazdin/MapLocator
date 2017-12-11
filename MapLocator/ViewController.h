//
//  ViewController.h
//  MapLocator
//
//  Created by Valentin Strazdin on 7/25/14.
//  Copyright (c) 2014 Valentin Strazdin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *map;


@end

