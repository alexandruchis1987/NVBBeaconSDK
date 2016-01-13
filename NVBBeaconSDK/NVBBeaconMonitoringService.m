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
#import "NVBBeaconSDKPrefix.pch" //to be taken out to check if it works without this as well

@interface NVBBeaconMonitoringService()
{
}

@property (strong, nonatomic) CLLocationManager* locationManager;//we have our own instance of location manager for handling the beacons interaction

@property (strong, nonatomic) NSMutableArray* pendingBeacons;//beacons discovered but yet retrieved information from the server
@property (strong, nonatomic) NSMutableArray* confirmedBecons; //beacons for info was received and the view wasn't dismissed
@property (strong, nonatomic) NSMutableArray* bannedBeacons; //beacons which were dismissed form the promotion view

@property (assign, nonatomic) BOOL notificationViewIsShown; //signalling if the notification view was already shown or not
@property (strong, nonatomic) NSMutableDictionary* dictVisibility;//used to keep track which of the promotions was shown for a beacon

@property (strong, nonatomic) CBCentralManager* bluetoothManager;//used for being notified if bluetooth is off or not

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


/**
 * Method which deals with starting the beacon discovery process
 */
-(void) startServices
{
    DDLogDebug (@"getRegisteredBeacons enter ");
    [self checkBluetooth];
    
    //initialising controls
    self.pendingBeacons = [[NSMutableArray alloc] init];
    self.confirmedBecons = [[NSMutableArray alloc] init];
    self.bannedBeacons = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    
    //to be taken out sa vad de nu trebuie scoasa
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBeacons) name:@"updateInternalBadgeNotification" object:nil];
    
    //retrieving the beacons which we will be monitoring
    [[NVBDataStore sharedInstance] getRegisteredBeacons:^(NSArray *responseArrayList, NSString *error) {
        if (responseArrayList)
            DDLogDebug (@"Setting up monitoring for %ld regions", responseArrayList.count );
        for (NVBBeacon* beacon in responseArrayList)
            [self setupRegion:beacon];
   }];
    
    
}


/**
 * Method which starts monitoring for a beacon once a beacon object was received from the server
 */

- (void)setupRegion: (NVBBeacon*) beacon {
    //retrivegin the uuid for the estimote beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beacon.uuid];
    
    
    //start monitoring for events for that particular region
    
    CLBeaconRegion* beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[beacon.major integerValue] minor:[beacon minor] identifier:[NSString stringWithFormat:@"com.invibe.%@", [beacon promoIdentifier]]];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:beaconRegion];
    
}


-(void) resetVisibilityWithRegion:(CLRegion*)region
{
    DDLogDebug (@"Enter for region %@", region.identifier );
    
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

#pragma mark Bluetooth Central Manager related

/////////////////////////////////////////////////////////////////
/*
 * Methods related to the Bluetooth Manager
 */
/////////////////////////////////////////////////////////////////


/**
 * Initialising the bluetooth manager in order to see if its active or not
 */
-(void) checkBluetooth
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
    });
}

/**
 * Getting notifications about the bluetooth state
 */
 
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
    
    DDLogDebug (@" Updated with state %@ ", stateString);
}



#pragma mark Location Manager related

/////////////////////////////////////////////////////////////////
/*
 * Methods related to the Location Manager
 */
/////////////////////////////////////////////////////////////////


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DDLogDebug (@"new status is %d", status);
    
    if ((status == kCLAuthorizationStatusNotDetermined)  || (status == kCLAuthorizationStatusDenied)
        || (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager requestStateForRegion:region];
}



#pragma mark Beacons

/////////////////////////////////////////////////////////////////
/*
 * Methods related to beacon detection events
 */
/////////////////////////////////////////////////////////////////


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    DDLogDebug(@"Enter for region %@ ", region.identifier);
    
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
        DDLogDebug(@"Inside for region %@ ", region.identifier);
        //Start Ranging
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
        DDLogDebug(@"Outside for region %@ ", region.identifier);
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
        DDLogDebug(@"Outside for region %@ ", region.identifier);
        
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
                        DDLogDebug(@" Notification view is already shown so we don't do anything");
                    }
                }
                else
                {
                    DDLogError(@" Exit promotion is nil");
                }
            }
        }
        
        if (region != nil)
        {
            [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        }
        else
        {
            DDLogError (@"For some reasons the beacon region was null so we abort");
        }
        
        
        [self resetVisibilityWithRegion:region];
        
    }
    @catch (NSException *exception) {
        DDLogError (@"Exception %@", exception);
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
                            DDLogDebug(@"We update with state immediate");
                            if (tempBeacon.immediatePromotion == nil)
                            {
                                DDLogDebug(@"We have no immediate state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideImmediate == YES)
                            {
                                DDLogDebug(@"We already shown near so we move on");
                                continue;
                            }
                            
                            
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.immediatePromotion];
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                DDLogDebug(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideImmediate = YES;
                            };
                            
                        }
                        if (tempBeacon.proximity == CLProximityNear)
                        {
                            DDLogDebug(@"We update with state near");
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.nearPromotion];
                            if (tempBeacon.nearPromotion == nil)
                            {
                                DDLogDebug(@"We have no near state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideNear == YES)
                            {
                                DDLogDebug(@"We already shown near so we move on");
                                continue;
                            }
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                DDLogDebug(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideNear = YES;
                            };
                            
                        }
                        if (tempBeacon.proximity == CLProximityFar)
                        {
                            DDLogDebug(@"We update with state far");
                            [beaconNotificationView updateWithPromotion:tempBeacon andPromotion:tempBeacon.farPromotion];
                            
                            if (tempBeacon.farPromotion == nil)
                            {
                                DDLogDebug(@"We have no far state");
                                continue;
                            }
                            if (((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideFar == YES)
                            {
                                DDLogDebug(@"We already shown near so we move on");
                                continue;
                            }
                            
                            beaconNotificationView.notificationSuccessfullRedirection = ^()
                            {
                                DDLogDebug(@"Notification view when changing immediate near far is successfully redirecte");
                                self.notificationViewIsShown = NO;
                                ((NVBShowBeacon*)self.dictVisibility[region.identifier]).hideFar = YES;
                            };
                            
                        }
                        
                        beaconNotificationView.notificationViewDismissActionBlock = ^()
                        {
                            DDLogDebug(@"Notification view when changing immediate near far was dismissed");
                            self.notificationViewIsShown = NO;
                            [self.bannedBeacons addObject:tempBeacon];
                            [self.confirmedBecons removeObject:tempBeacon];
                        };
                        
                        
                        self.notificationViewIsShown = YES;
                        [beaconNotificationView animateVerticallyFromBottomWithOption:UIViewAnimationCurveEaseIn];
                    }
                    else
                    {
                        DDLogDebug(@"We had a new state but we dont show it because the view is already shown");
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
            DDLogDebug (@"We found a new beacon with major %@ and minor %@", beacon.major, beacon.minor);
            
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


/**
 * Method which retrieves the promotions for a specific beacon
 */
-(void) getPromotions:(NVBBeacon*) latestBeacon

{
    DDLogDebug(@"Enter");
    [[NVBDataStore sharedInstance] getPromotionsWithBeaconId:[latestBeacon promoIdentifier] onCompletion:^(NVBBeacon *beaconResponse, NSString* error) {
        if (error != nil)
        {
            DDLogError (@" Error while getting the invitations so we remove it from pending so we can try again later %@", error);
            [self.pendingBeacons removeObject:latestBeacon];//we remove it from pending since we received a reply for it
        }
        else
        {
            [self.confirmedBecons addObject:latestBeacon];
            [self.pendingBeacons removeObject:latestBeacon];
            
            DDLogDebug (@" We received invitations for beacon %@ and we move it to confirmed",[latestBeacon beaconIdentifier]);
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
                DDLogDebug (@"We have no enter region promotions ");
                return;
            }
            
            //we show it only if it wasnt shown before
            if (self.notificationViewIsShown == NO)
            {
                DDLogDebug (@" The overlay was not shown so we can show it");
                
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
                    DDLogDebug (@"Dismiss was pressed so we move to banned for %@", [latestBeacon beaconIdentifier]);
                    self.notificationViewIsShown = NO;
                    [self.bannedBeacons addObject:latestBeacon];
                    [self.confirmedBecons removeObject:latestBeacon];
                };
                
                beaconNotificationView.notificationSuccessfullRedirection = ^()
                {
                    DDLogDebug (@"Ok was pressed for %@", [latestBeacon beaconIdentifier]);
                    //we show the accept gift screen
                    self.notificationViewIsShown = NO;
                    
                };
                
                [beaconNotificationView animateVerticallyFromBottomWithOption:UIViewAnimationCurveEaseIn];
            }
            else
            {
            }
        }
    }];
    
}


/**
 * Method used to subscribe to a channel/beacon. Used for push notifications and backend analytics
 */
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
                        DDLogError(@"subscription error: %@ ",error);
                    }
                }];
                
            }
        } else {
            DDLogError(@"Channels array is nil!");
        }
    } else {
        DDLogError(@"Channel is nil!");
    }
}


/**
 * Method used to unsubscrieb to a channel/beacon. Used for push notifications and backend analytics
 */

- (void) unsubscribeFromInvibe:(NSString*)pubnubChannel withCompletionBlock:(booleanSuccessBlock)handlerBlock
{
    [[NVBDataStore sharedInstance] unsubscribeFromInvibe:pubnubChannel withCompletion:handlerBlock];
}

@end