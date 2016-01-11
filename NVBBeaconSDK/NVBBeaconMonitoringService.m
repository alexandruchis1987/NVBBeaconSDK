//
//  NVBBeaconMonitoringService.m
//  Invibe
//
//  Created by Alexandru Chis 16/03/2014
//


#import "NVBBeaconMonitoringService.h"
#import "NVBDataStore.h"
#import "NVBNotificationView.h"
#import "UIView+NVBAnimations.h"
#import "NVBBeacon.h"
#import "NVBShowBeacon.h"

#define ESTIMOTE_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

#define INVIBE_REGION1 @"com.invibe.12508"
#define INVIBE_REGION2 @"com.invibe.22114"
#define INVIBE_REGION3 @"com.invibe.35052"

#define INVIBE_REGION4 @"com.invibe.13686"
#define INVIBE_REGION5 @"com.invibe.32831"
#define INVIBE_REGION6 @"com.invibe.52584"
#define INVIBE_REGION7 @"com.invibe.55482"
#define INVIBE_REGION8 @"com.invibe.44282"
#define INVIBE_REGION9 @"com.invibe.46499"
#define INVIBE_REGION10 @"com.invibe.51752"



@interface NVBBeaconMonitoringService()
{
}

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion1;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion2;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion3;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion4;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion5;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion6;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion7;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion8;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion9;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion10;


@property (strong, nonatomic) NSMutableArray* pendingBeacons;
@property (strong, nonatomic) NSMutableArray* confirmedBecons;
@property (strong, nonatomic) NSMutableArray* bannedBeacons;
@property (assign, nonatomic) BOOL notificationViewIsShown;
@property (assign, nonatomic) BOOL blockNotifications;
@property (strong, nonatomic) CBCentralManager* bluetoothManager;

@property (strong, nonatomic) NSMutableDictionary* dictVisibility;

@end


@implementation NVBBeaconMonitoringService

+ (NVBBeaconMonitoringService *)sharedInstance {
    static dispatch_once_t onceToken;
    static NVBBeaconMonitoringService *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    self.dictVisibility = [[NSMutableDictionary alloc] init];
    
    return self;
}



-(void) startServices
{
    _locationManager = [[CLLocationManager alloc] init];
    _pendingBeacons = [[NSMutableArray alloc] init];
    _confirmedBecons = [[NSMutableArray alloc] init];
    _bannedBeacons = [[NSMutableArray alloc] init];
    
    [self checkBluetooth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBeacons) name:@"updateInternalBadgeNotification" object:nil];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
}

-(void) checkBluetooth
{
    //    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    //    NSString *version = [info objectForKey:@"CFBundleVersion"];
    //    NSString* storedVersion = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_version"];
    //    if (![storedVersion isEqualToString:version])
    //    {
    //        [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"current_version"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        //            [self centralManagerDidUpdateState:self.bluetoothManager];
    });
    //    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(central.state)
    {
        case CBCentralManagerStateResetting:
        {
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            stateString = @"Bluetooth is currently powered off.";
            
            [self unsubscribeFromInvibe:nil withCompletionBlock:nil];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            stateString = @"Bluetooth is currently powered off.";
            [self unsubscribeFromInvibe:nil withCompletionBlock:nil];
            
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            stateString = @"Bluetooth is currently powered off.";
            [[NVBDataStore sharedInstance] syncUnsubscribeFromChannels];
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            stateString = @"Bluetooth is currently powered on and available to use.";
            break;
        }
        default: stateString = @"State unknown, update imminent."; break;
    }
    
    NSLog (@" avem state %@ ", stateString);
}




- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog (@"status is %d", status);
    
    if ((status == kCLAuthorizationStatusNotDetermined)  || (status == kCLAuthorizationStatusDenied)
        || (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        
        [self initRegion];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion1];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion2];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion3];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion4];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion5];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion6];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion7];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion8];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion9];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion10];
    }
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager requestStateForRegion:region];
}

- (void)initRegion {
    //retrivegin the uuid for the estimote beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:ESTIMOTE_UUID];
    
    
    //defining our region for tracking
    
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        
        NSLog(@"Background updates are available for the app.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }
    
    //start monitoring for events for that particular region
    self.beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:12508 identifier:INVIBE_REGION1];
    self.beaconRegion1.notifyEntryStateOnDisplay = YES;
    self.beaconRegion1.notifyOnEntry = YES;
    self.beaconRegion1.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion1];
    
    //region 2
    
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:22114 identifier:INVIBE_REGION2];
    self.beaconRegion2.notifyEntryStateOnDisplay = YES;
    self.beaconRegion2.notifyOnEntry = YES;
    self.beaconRegion2.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion2];
    
    //region 3
    
    self.beaconRegion3 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:35052 identifier:INVIBE_REGION3];
    self.beaconRegion3.notifyEntryStateOnDisplay = YES;
    self.beaconRegion3.notifyOnEntry = YES;
    self.beaconRegion3.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion3];
    
    //region 4
    
    self.beaconRegion4 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:13686 identifier:INVIBE_REGION4];
    self.beaconRegion4.notifyEntryStateOnDisplay = YES;
    self.beaconRegion4.notifyOnEntry = YES;
    self.beaconRegion4.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion4];
    
    //region 5
    
    self.beaconRegion5 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:32831 identifier:INVIBE_REGION5];
    self.beaconRegion5.notifyEntryStateOnDisplay = YES;
    self.beaconRegion5.notifyOnEntry = YES;
    self.beaconRegion5.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion5];
    
    //region 6
    
    self.beaconRegion6 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:52584 identifier:INVIBE_REGION6];
    self.beaconRegion6.notifyEntryStateOnDisplay = YES;
    self.beaconRegion6.notifyOnEntry = YES;
    self.beaconRegion6.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion6];
    
    
    //region 7
    
    self.beaconRegion7 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:55482 identifier:INVIBE_REGION7];
    self.beaconRegion7.notifyEntryStateOnDisplay = YES;
    self.beaconRegion7.notifyOnEntry = YES;
    self.beaconRegion7.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion7];
    
    
    //region 8
    
    self.beaconRegion8 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:44282 identifier:INVIBE_REGION8];
    self.beaconRegion8.notifyEntryStateOnDisplay = YES;
    self.beaconRegion8.notifyOnEntry = YES;
    self.beaconRegion8.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion8];
    
    //region 9
    
    self.beaconRegion9 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:46499 identifier:INVIBE_REGION9];
    self.beaconRegion9.notifyEntryStateOnDisplay = YES;
    self.beaconRegion9.notifyOnEntry = YES;
    self.beaconRegion9.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion9];
    
    //region 10
    
    self.beaconRegion10 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:51752 identifier:INVIBE_REGION10];
    self.beaconRegion10.notifyEntryStateOnDisplay = YES;
    self.beaconRegion10.notifyOnEntry = YES;
    self.beaconRegion10.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion10];
    
}



- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    //to be taken out
    //[self scheduleLocalNotification:@"Enter region1"];
    
    //to be taken out new new
    //        [self resetVisibilityWithRegion:region];
    
    
    
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"text"] = @"enter";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBeacon" object:nil userInfo:dict];
    
    @try {
        NSLog(@"NVBBeaconMonitorinService:: Beacon Found");
        if (region)
        {
            [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        }
        else
        {
            NSLog (@"For some reasons the beacon region was null so we abort");
        }
    }
    @catch (NSException *exception) {
        NSLog (@"Exception didEnterregion %@", exception);
    }
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state == CLRegionStateInside) {
        //Start Ranging
        //to be taken out
        //[self scheduleLocalNotification:@"Enter region"];
        
        //to be taken out new new
        //        [self resetVisibilityWithRegion:region];
        
        NSString* strIdentifier = region.identifier;
        NSArray* arr = [strIdentifier componentsSeparatedByString:@"."];
        NSString* regionMajorIdentifier = arr[2];
        
        if (regionMajorIdentifier)
        {
            [[NVBDataStore sharedInstance] subscribeToInvibeWithChannel:regionMajorIdentifier onCompletion:^(BOOL success, NSString *error) {
                if (success == NO)
                    NSLog (@"Failed to subscribe to channel %@ ", error);
            }];
        }
        
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    }
    else{
        //Stop Ranging
        [self resetVisibilityWithRegion:region];
        
        NSString* strIdentifier = region.identifier;
        NSArray* arr = [strIdentifier componentsSeparatedByString:@"."];
        NSString* regionMajorIdentifier = arr[2];
        
        [self unsubscribeFromInvibe:regionMajorIdentifier withCompletionBlock:nil];
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    @try {
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict[@"text"] = @"exit";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBeacon" object:nil userInfo:dict];
        
        NSString* strIdentifier = region.identifier;
        NSArray* arr = [strIdentifier componentsSeparatedByString:@"."];
        NSString* regionMajorIdentifier = arr[2];
        
        for (NVBBeacon* beacon in self.confirmedBecons)
        {
            if ([beacon.major integerValue] == [regionMajorIdentifier integerValue])
            {
                if (beacon.exitPromotion.title != nil)
                {
                    if (self.notificationViewIsShown == NO)
                    {
                        self.notificationViewIsShown = YES;
                        
                        NVBNotificationView* beaconNotificationView;
                        if ([UIScreen mainScreen].bounds.size.height == 568) {
                            beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView" owner:self options:nil] objectAtIndex:0];
                        }
                        else
                        {
                            beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView~375w" owner:self options:nil] objectAtIndex:0];
                            
                        }
                        [beaconNotificationView updateWithPromotion:beacon andPromotion:beacon.exitPromotion];
                        [beaconNotificationView animateVerticallyFromBottomWithOption:UIViewAnimationCurveEaseIn];
                    }
                    else
                    {
                        NSLog(@" Notification view is already shown so we don't do anything");
                    }
                }
                else
                {
                    NSLog(@" Exit promotion is nil");
                }
            }
        }
        
        if (region != nil)
        {
            [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        }
        else
        {
            NSLog (@"For some reasons the beacon region was null so we abort");
        }
        
        
        [self resetVisibilityWithRegion:region];
        
    }
    @catch (NSException *exception) {
        NSLog (@"Exception in did exit region %@", exception);
    }
}


-(void) resetVisibilityWithRegion:(CLRegion*)region
{
    self.dictVisibility[region.identifier] = [[NVBShowBeacon alloc] init];
    
    NSString* strIdentifier = region.identifier;
    NSArray* arr = [strIdentifier componentsSeparatedByString:@"."];
    NSString* regionMajorIdentifier = arr[2];
    
    NSMutableArray* arrToBeDeleted = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < self.confirmedBecons.count; i++)
    {
        NVBBeacon* tempBeacon = [self.confirmedBecons objectAtIndex:i];
        
        if ([[tempBeacon beaconIdentifier] integerValue] == [regionMajorIdentifier integerValue])
        {
            [arrToBeDeleted addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    for (int j = 0; j < arrToBeDeleted.count; j++)
    {
        [self.confirmedBecons removeObjectAtIndex:[arrToBeDeleted[j] integerValue]];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //beacons found in the region
    

    
    for (int i = 0; i < beacons.count; i++)
    {
        CLBeacon* beacon = [beacons objectAtIndex:i];
        NVBBeacon* myBeacon = [NVBBeacon makeWithBeacon:beacon];
        if (myBeacon.proximity == CLProximityUnknown)
            myBeacon.proximity = CLProximityFar;
        
        [self processAllBeacons:myBeacon];
        
        if ([self.confirmedBecons containsObject:myBeacon])
        {
            //it means we already had it, we will check if the state hasn changed by any chance
            for (int i = 0; i < self.confirmedBecons.count; i++)
            {
                NVBBeacon* tempBeacon = [self.confirmedBecons objectAtIndex:i];
                if ([tempBeacon isEqual:myBeacon])
                {
                    if (self.notificationViewIsShown == NO)
                    {
                        NVBNotificationView* beaconNotificationView;
                        if ([UIScreen mainScreen].bounds.size.height == 568) {
                            beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView" owner:self options:nil] objectAtIndex:0];
                        }
                        else
                        {
                            beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView~375w" owner:self options:nil] objectAtIndex:0];
                        }
                        
                        
                        if (tempBeacon.proximity == CLProximityImmediate)
                        {
                            NSLog(@"We update with state immediate");
                            if (tempBeacon.immediatePromotion == nil)
                            {
                                NSLog(@"We have no immediate state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideImmediate == YES)
                            {
                                NSLog(@"We already shown near so we move on");
                                continue;
                            }
                            
                            
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.immediatePromotion];
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                NSLog(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideImmediate = YES;
                            };
                            
                        }
                        if (tempBeacon.proximity == CLProximityNear)
                        {
                            NSLog(@"We update with state near");
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.nearPromotion];
                            if (tempBeacon.nearPromotion == nil)
                            {
                                NSLog(@"We have no near state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideNear == YES)
                            {
                                NSLog(@"We already shown near so we move on");
                                continue;
                            }
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                NSLog(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideNear = YES;
                            };
                            
                        }
                        if (tempBeacon.proximity == CLProximityFar)
                        {
                            NSLog(@"We update with state far");
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.farPromotion];
                            
                            if (tempBeacon.farPromotion == nil)
                            {
                                NSLog(@"We have no far state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideFar == YES)
                            {
                                NSLog(@"We already shown near so we move on");
                                continue;
                            }
                            
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                NSLog(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideFar = YES;
                            };
                            
                        }
                        
                        beaconNotificationView.notificationViewDismissActionBlock = ^()
                        {
                            NSLog(@"Notification view when changing immediate near far was dismissed");
                            self.notificationViewIsShown = NO;
                            [self.bannedBeacons addObject:tempBeacon];
                            [self.confirmedBecons removeObject:tempBeacon];
                        };
                        
                        
                        self.notificationViewIsShown = YES;
                        [beaconNotificationView animateVerticallyFromBottomWithOption:UIViewAnimationCurveEaseIn];
                    }
                    else
                    {
                        NSLog(@"We had a new state but we dont show it because the view is already shown");
                    }
                    
                    break;
                }
            }
            
        }
        else if ([self.pendingBeacons containsObject:myBeacon])
        {
            //do noth
            //we do nothign because because probably we are retrieving the info from the server for it
        }
        else if ([self.bannedBeacons containsObject:myBeacon])
        {
            //do noth
        }
        
        else
        {
            [self.pendingBeacons addObject:myBeacon];
            //it a new new beacon so we retrieve the info from the server
            NSLog (@"NVBBeaconMonitoringService we found a new beacon with major %@ and minor %@", beacon.major, beacon.minor);
            
            [self getPromotions:myBeacon];
            
        }
    }
    
    
    
}


-(void) processAllBeacons:(NVBBeacon*) myBeacon
{
    if ([self.confirmedBecons containsObject:myBeacon])
    {
        //it means we already had it, we will check if the state hasn changed by any chance
        for (int i = 0; i < self.confirmedBecons.count; i++)
        {
            NVBBeacon* tempBeacon = [self.confirmedBecons objectAtIndex:i];
            if ([tempBeacon isEqual:myBeacon])
            {
                if (tempBeacon.proximity != myBeacon.proximity)
                {
                    tempBeacon.proximity = myBeacon.proximity;
                    
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                    if (tempBeacon.proximity == CLProximityNear)
                    {
                        dict[@"text"] = @"confirmed near";
                        [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                    }
                    else if (tempBeacon.proximity == CLProximityImmediate)
                    {
                        dict[@"text"] = @"confirmed immediate";
                        [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                    }
                    else if (tempBeacon.proximity == CLProximityFar)
                    {
                        dict[@"text"] = @"confirmed far";
                        
                        [self unsubscribeFromInvibe:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBeacon" object:nil userInfo:dict];
                }
            }
        }
    }
    
    else if ([self.pendingBeacons containsObject:myBeacon])
    {
        for (int i = 0; i < self.pendingBeacons.count; i++)
        {
            NVBBeacon* tempBeacon = [self.pendingBeacons objectAtIndex:i];
            if ([tempBeacon isEqual:myBeacon])
            {
                if (tempBeacon.proximity != myBeacon.proximity)
                {
                    tempBeacon.proximity = myBeacon.proximity;
                    
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                    if (tempBeacon.proximity == CLProximityNear)
                    {
                        dict[@"text"] = @"pending near";
                        [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                    }
                    else if (tempBeacon.proximity == CLProximityImmediate)
                    {
                        dict[@"text"] = @"pending immediate";
                        [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                    }
                    else if (tempBeacon.proximity == CLProximityFar)
                    {
                        dict[@"text"] = @"pending far";
                        [self unsubscribeFromInvibe:[myBeacon beaconIdentifier] withCompletionBlock:nil];
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBeacon" object:nil userInfo:dict];
                }
            }
        }
        
    }
    else
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        if (myBeacon.proximity == CLProximityNear)
        {
            dict[@"text"] = @"enter near";
            [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
        }
        else if (myBeacon.proximity == CLProximityImmediate)
        {
            dict[@"text"] = @"enter immediate";
            [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
        }
        else if (myBeacon.proximity == CLProximityFar)
        {
            dict[@"text"] = @"enter far";
            if ([[NSUserDefaults standardUserDefaults] boolForKey:APP_FOREGROUND] == NO)//when first entering in the region besides the did enter region it gets here as well and to avoid an unsubscrieb we do this
                [self subscribeToInvibeWithChannel:[myBeacon beaconIdentifier] withCompletionBlock:nil];
            else
                [self unsubscribeFromInvibe:[myBeacon beaconIdentifier] withCompletionBlock:nil];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBeacon" object:nil userInfo:dict];
        
    }
}


-(void) getPromotions:(NVBBeacon*) latestBeacon

{
    NSLog(@"Enter");
    [[NVBDataStore sharedInstance] getPromotionsWithBeaconId:[latestBeacon promoIdentifier] onCompletion:^(NVBBeacon *beaconResponse, NSString* error) {
        if (error != nil)
        {
            NSLog (@" Error while getting the invitations so we remove it from pending so we can try again later %@", error);
            [self.pendingBeacons removeObject:latestBeacon];
        }
        else
        {
            [self.confirmedBecons addObject:latestBeacon];
            [self.pendingBeacons removeObject:latestBeacon];
            
            NSLog (@" We received invitations for beacon %@ and we move it to confirmed",[latestBeacon beaconIdentifier]);
            latestBeacon.enterPromotion = beaconResponse.enterPromotion;
            latestBeacon.exitPromotion = beaconResponse.exitPromotion;
            latestBeacon.nearPromotion = beaconResponse.nearPromotion;
            latestBeacon.immediatePromotion = beaconResponse.immediatePromotion;
            latestBeacon.farPromotion = beaconResponse.farPromotion;
            latestBeacon.name = beaconResponse.name;
            latestBeacon.id = beaconResponse.id;
            latestBeacon.venue = beaconResponse.venue;
            latestBeacon.venue_name = beaconResponse.venue_name;
            
            
            if (latestBeacon.enterPromotion == nil)
            {
                NSLog (@"We have no enter region promotions ");
                return;
            }
            
            //            if (self.blockNotifications == NO)
            //            {
            //                self.blockNotifications = YES;
            //
            //                                [self scheduleLocalNotification:[NSString stringWithFormat:@"Welcome to %@, swipe to enjoy the best inVibe gifts", latestBeacon.enterPromotion.title]];
            //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                    self.blockNotifications = NO;
            //                });
            //
            //            }
            
            //we show it only if it wasnt shown before
            if (self.notificationViewIsShown == NO)
            {
                NSLog (@" The overlay was not shown so we can show it");
                
                self.notificationViewIsShown = YES;
                NVBNotificationView* beaconNotificationView;
                if ([UIScreen mainScreen].bounds.size.height == 568) {
                    beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView" owner:self options:nil] objectAtIndex:0];
                }
                else
                {
                    beaconNotificationView = [[[NSBundle mainBundle] loadNibNamed:@"NVBNotificationView~375w" owner:self options:nil] objectAtIndex:0];
                    
                }
                
                [beaconNotificationView updateWithPromotion:latestBeacon andPromotion:latestBeacon.enterPromotion];
                beaconNotificationView.notificationViewDismissActionBlock = ^()
                {
                    NSLog (@"Dismiss was pressed so we move to banned for %@", [latestBeacon beaconIdentifier]);
                    self.notificationViewIsShown = NO;
                    [self.bannedBeacons addObject:latestBeacon];
                    [self.confirmedBecons removeObject:latestBeacon];
                };
                
                beaconNotificationView.notificationSuccessfullRedirection = ^()
                {
                    NSLog (@"Ok was pressed for %@", [latestBeacon beaconIdentifier]);
                    //we show the accept gift screen
                    self.notificationViewIsShown = NO;
                    
                };
                
                [beaconNotificationView animateVerticallyFromBottomWithOption:UIViewAnimationCurveEaseIn];
            }
            else
            {
            }
            
            //            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            //            if (state == UIApplicationStateBackground)
            //            {
            //                [self scheduleLocalNotification:[NSString stringWithFormat:
            //                                                     @"Congrats.. You got a gift!\nGo to your close %@ and redeem it!", beaconResponse.venue_name]];
            //            }
        }
    }];
    
}

-(void) updateBeacons
{
    if (self.bluetoothManager)
    {
        switch (self.bluetoothManager.state)
        {
            case CBCentralManagerStatePoweredOn:
            {
                NSLog (@"Bluetooth is on so all good");
                break;
            }
            default:
            {
                NSLog (@"we are unsubscribing from lal because bluetooth is turned off ");
                [self unsubscribeFromInvibe:nil withCompletionBlock:nil];
                break;
            }
        }
        
        return;
    }
    
}



- (void) subscribeToInvibeWithChannel: (NSString*) channel withCompletionBlock:(booleanSuccessBlock)completionBlock
{
    if (channel) {
        
        NSArray *channelNamesArray = @[channel];
        if (channelNamesArray) {
            if (completionBlock != nil)
            {
                
                [[NVBDataStore sharedInstance] subscribeToInvibeWithChannel:channel onCompletion:completionBlock];
            }
            else
            {
                [[NVBDataStore sharedInstance] subscribeToInvibeWithChannel:channel onCompletion:^(BOOL success, NSString *error) {
                    if (error)
                    {
                        NSLog(@"NVBRealTimeMessagingProxy: PubNub: subscription error: %@ ",error);
                    }
                }];
                
            }
        } else {
            NSLog(@"NVBRealTimeMessagingProxy: PubNub: channels array is nil!");
        }
    } else {
        NSLog(@"NVBRealTimeMessagingProxy: PubNub: subscribeToInvibeWithChannel: userToken is nil!");
    }
}


- (void) unsubscribeFromInvibe:(NSString*)pubnubChannel withCompletionBlock:(booleanSuccessBlock)handlerBlock
{
    [[NVBDataStore sharedInstance] unsubscribeFromInvibe:pubnubChannel withCompletion:handlerBlock];
}

@end