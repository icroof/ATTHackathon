//
//  ViewController.m
//  BeaconTest
//
//  Created by Ian Roof on 1/2/16.
//  Copyright © 2016 Ian Roof. All rights reserved.
//

#import "ViewController.h"
#import "M2X.h"


@interface ViewController ()
{

}

@property (nonatomic, strong) M2XStream *stream;
@property (nonatomic, strong) NSString *M2XDevice;
@property (nonatomic, strong) NSString *M2XStream;
@property (nonatomic, strong) NSMutableArray *values;

@end



@implementation ViewController
{
    M2XClient *client;
    M2XDevice *device;
    CLBeacon* lastBeacon;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.values = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
 
   [self setUpM2X];

 
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
   
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"01122334-4556-6778-899A-ABBCCDDEEFF0"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.giganticapps.beacon"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
   // self.beaconFoundLabel.text = @"No";
    lastBeacon = nil;
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
  
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons firstObject];
    
    
    //NSLog(@"BEACON COUNT %lu", (unsigned long)[beacons count]);
    
   // NSLog(@"FOUND A BEACON with UUID of %@ and major %@ and minor %@ and RSSI of %@", beacon.proximityUUID.UUIDString, [NSString stringWithFormat:@"%@", beacon.major],[NSString stringWithFormat:@"%@", beacon.minor], [NSString stringWithFormat:@"%li", (long)beacon.rssi]);
    
    if ([beacon.proximityUUID isEqual:lastBeacon.proximityUUID])
    {
        return;
    }
    lastBeacon = beacon;
    NSLog(@"FOUND A BEACON with UUID of %@ and major %@ and minor %@ and RSSI of %@", beacon.proximityUUID.UUIDString, [NSString stringWithFormat:@"%@", beacon.major],[NSString stringWithFormat:@"%@", beacon.minor], [NSString stringWithFormat:@"%li", (long)beacon.rssi]);
    
    [self addDataPoint:10];
    [self saveValuesToM2X:nil];
    

}


- (void)setUpM2X
{
   
    NSString *M2XKey = @"df1ed9fe17c76ffc6505affd37143438"; //config[@"key"];
    self.M2XDevice = @"2bc5404b09c011508005c8a0e75dd757"; //config[@"device"];
    self.M2XStream = @"temperature"; //config[@"stream"];
    
    client = [[M2XClient alloc] initWithApiKey:M2XKey];
    device = [[M2XDevice alloc] initWithClient:client attributes:@{@"id": self.M2XDevice}];
    _stream = [[M2XStream alloc] initWithClient:client device:device attributes:@{@"name": self.M2XStream}];
    
}

- (void)addDataPoint:(int) presence
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDate *now = [NSDate date];
    
    //  NSTimeInterval secondsInFiveHours = 5 * 60 * 60;
    // NSDate *dateFiveHoursAhead = [now dateByAddingTimeInterval:secondsInFiveHours * -1];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    
    
    // NSLog(@"ISO-8601 date: %@", [NSString stringWithFormat:@"%@.000Z",iso8601String]);
    // NSLog(@"TEST 2015-01-02T00:00:00.000Z");
    
    /* NSDictionary *item = @{ @"value": [NSString stringWithFormat:@"%i", gesture], @"timestamp":[NSString stringWithFormat:@"%@.000Z",iso8601String]};*/
    
    NSDictionary *item = @{ @"value": [NSString stringWithFormat:@"%i", presence], @"timestamp":iso8601String};
    [self.values insertObject:item atIndex:0];
    
    
}

- (IBAction)saveValuesToM2X:(id)sender
{
    NSMutableArray *valuesToSave = self.values;
    self.values = [NSMutableArray new];
    
    
    [_stream postValues:valuesToSave completionHandler:^(M2XResponse *response) {
        if (response.error) {
            NSLog(@"Warning! Failed to post values to M2X (%@)", response.errorObject.localizedDescription);
            return;
        }
        
        NSString *text = [NSString stringWithFormat:@"M2X: Successfully posted %lu values to the M2X stream!", (unsigned long)valuesToSave.count];
        // [[[UIAlertView alloc] initWithTitle:@"Success!"
        //                           message:text
        //                        delegate:nil cancelButtonTitle:@"Ok"
        //             otherButtonTitles:nil] show];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
