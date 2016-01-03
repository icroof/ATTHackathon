//
//  ViewController.h
//  BeaconTest
//
//  Created by Ian Roof on 1/2/16.
//  Copyright © 2016 Ian Roof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate>


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
//test

@end

