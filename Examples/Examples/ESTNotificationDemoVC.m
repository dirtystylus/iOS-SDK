//
//  ESTNotificationDemoVC.m
//  Examples
//
//  Created by Grzegorz Krukiewicz-Gacek on 18.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTNotificationDemoVC.h"
#import "ESTBeaconManager.h"

@interface ESTNotificationDemoVC () <ESTBeaconManagerDelegate>


@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;

@property (nonatomic, strong) IBOutlet UIView            *mainView;
@property (nonatomic, strong) IBOutlet UISwitch          *enterRegionSwitch;
@property (nonatomic, strong) IBOutlet UISwitch          *exitRegionSwitch;
@property (nonatomic, strong) UIImageView       *imageView;

@end

@implementation ESTNotificationDemoVC

- (id)initWithBeacon:(ESTBeacon *)beacon
{
    self = [super init];
    if (self)
    {
        self.beacon = beacon;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Notification Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.mainView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.mainView.frame = frame;

    /*
     * BeaconManager setup.
     */
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID
                                                                 major:[self.beacon.major unsignedIntValue]
                                                                 minor:[self.beacon.minor unsignedIntValue]
                                                            identifier:@"RegionIdentifier"];
    self.beaconRegion.notifyOnEntry = self.enterRegionSwitch.isOn;
    self.beaconRegion.notifyOnExit = self.exitRegionSwitch.isOn;
    
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"You have entered Bluecadet! Please open the Bluecadet app to see more about what’s around you.";
    AudioServicesPlaySystemSound(1007);
    NSString *notificationType = @"entry";
    NSDictionary *data = [NSDictionary dictionaryWithObject:notificationType forKey:@"payload"];
    [notification setUserInfo:data];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"You’re now leaving Bluecadet! You might be interested in other Fishtown locations.";
    AudioServicesPlaySystemSound(1003);
    NSString *notificationType = @"exit";
    NSDictionary *data = [NSDictionary dictionaryWithObject:notificationType forKey:@"payload"];
    [notification setUserInfo:data];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark -

- (void)switchValueChanged
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    
    self.beaconRegion.notifyOnEntry = self.enterRegionSwitch.isOn;
    self.beaconRegion.notifyOnExit = self.exitRegionSwitch.isOn;
    
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"initWithCoder Notification received");
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didlocalNotificationReceived:) name:nil object:nil];
    }
    return self;
}

- (void)didlocalNotificationReceived:(NSNotification *)notification
{
    NSLog(@"Local notification %@", [notification.userInfo objectForKey:@"payload"]);
    if (notification) {
        UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                        initWithTitle:@"Welcome Back" message:@"Launched from Notification!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        // Display the Hello World Message
        [helloWorldAlert show];
    }
}


@end
