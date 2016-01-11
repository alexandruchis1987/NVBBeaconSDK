//
//  NVBDataStore.m
//
//  Created by Alex Chis on 28/06/13.
//  Copyright (c) 2013 Alex Chis. All rights reserved.
//


#import "NVBDataStore.h"


#define NVB_API_BASE_URL @"https://invibe-deploy.herokuapp.com/api/v1/"
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_STATUS_BAR_DISPLACEMENT IS_IOS7 ? 20 : 0


static NSString * const kInvibeAPIBaseURLString = NVB_API_BASE_URL;


@interface NVBDataStore()<CLLocationManagerDelegate>
{
    float lat;
    float longi;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) BOOL locationUpdateLocked;
@property (nonatomic, assign) BOOL locationUpdateNeeded;

@property (nonatomic, strong) NSString* stateBeacon;
@property (nonatomic, strong) NSString* lastBeacon;
@property (nonatomic, strong) NSTimer* timerBeacon;



@end


@implementation NVBDataStore

+ (NVBDataStore *)sharedInstance
{
    static NVBDataStore *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NVBDataStore alloc] initWithBaseURL:[NSURL URLWithString:kInvibeAPIBaseURLString]];
    });
    return _instance;
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Cache-Control" value:@"no-cache"];
    
    
    self.operationsQueue = [[NSOperationQueue alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(memoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    
    return self;
}

-(void)logout{
    [self setDefaultHeader:@"Authorization" value:@""];
}


- (void)memoryWarning:(NSNotification *)notification
{
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/////////////////////////////////////////////////////////////////
/*
 * Methods related to the application id
 */
/////////////////////////////////////////////////////////////////

#pragma mark Application Id

- (NSString *)getApplicationId
{
    return self.applicationId;
}


-(void) setApplicationId:(NSString*) applicationId
{
    self.applicationId = applicationId;
}

#pragma mark Location Services
/////////////////////////////////////////////////////////////////
/*
 * Methods related to location services
 */
/////////////////////////////////////////////////////////////////


/**
 * Method used for starting the location services with authorization for receiving updates while being in foreground
 */

- (void)startLocationServicesForeground {
    NSLog (@"startLocationServicesBackground");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 25.0f; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    
    
    if(IS_IOS8) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        
        
    } else {
        NSLog(@"Location services is not enabled");
    }
}



/**
 * Method used for starting the location services with authorization for receiving updates while being in the background as well
 */
- (void)startLocationServicesBackground {
    NSLog (@"startLocationServicesBackground");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 25.0f; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    
    if(IS_IOS8) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        NSLog(@"Location services is not enabled");
    }
}


/**
 * Method used for stopping the location services
 */


- (void)stopLocationServices {
    [self.locationManager stopUpdatingHeading];
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied)
    {
        NSLog (@"Location is Stauts Denied");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationDenied" object:nil];
    }
}



#pragma mark Channels

/////////////////////////////////////////////////////////////////
/*
 * Methods related to beacon channel subscribtion
 */
/////////////////////////////////////////////////////////////////


/**
 * Method use for subscribing to a channel represented by a detected beacon
 */
-(void) subscribeToPubnubWithChannel:(NSString*) channel andUUID:(NSString*) uuid
{
    
    NSDictionary *parameters = @{@"uuid":uuid,
                                 @"channel":channel,
                                 };
    [self postPath:@"/api/v1/pubnubconnect/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog (@"Backend subscribeToPubnubWithChannel success ");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog (@"Backend subscribeToPubnubWithChannel failure ");
    }
     ];
}


/**
 * Method use for unsubscribing from all channels
 */

-(void)syncUnsubscribeFromChannels{
    self.lastBeacon = nil;
    self.stateBeacon = @"2";
    
    [self.timerBeacon invalidate];
    self.timerBeacon = nil;
    [self updateBeaconRequests];
}


/**
 * Method use for unsubscribing to a channel represented by a detected beacon
 */


-(void)unsubscribeFromInvibe:(NSString*) pubnub withCompletion:(booleanSuccessBlock)completion{
    //to be taken out
    NSLog (@"data store unsubscribe from %@", pubnub);
    
    self.lastBeacon = pubnub;
    self.stateBeacon = @"2";
    
    [self.timerBeacon invalidate];
    self.timerBeacon = nil;
    self.timerBeacon = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateBeaconRequests) userInfo:nil repeats:NO];
    
}


/**
 * Method use for subscribing to a channel represented by a detected beacon
 */


-(void)subscribeToInvibeWithChannel:(NSString*) channel onCompletion:(booleanSuccessBlock)completion{
    //to be taken out
    NSLog (@"data store subscribe from %@", channel);
    
    
    self.lastBeacon = channel;
    self.stateBeacon = @"1";
    
    [self.timerBeacon invalidate];
    self.timerBeacon = nil;
    self.timerBeacon = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateBeaconRequests) userInfo:nil repeats:NO];
    
}


/**
 * Method used for communicating with the server related to a subscribe/unsubscribe to a particular beacon channel
 */

-(void) updateBeaconRequests
{
    if (self.stateBeacon == nil)
    {
        //do nothing
    }
    else if ([self.stateBeacon isEqualToString:@"1"])
    {
        self.stateBeacon = nil;
        NSDictionary *parameters = @{
                                     @"channel":self.lastBeacon
                                     };
        
        //to be taken out
        NSLog (@"calling subscribe with params %@", parameters);
        
        [self postPath:@"subscription/subscribe/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (error) NSLog(@" %@",error);
            
        }];
    }
    else if  ([self.stateBeacon isEqualToString:@"2"])
    {
        
        self.stateBeacon = nil;
        NSMutableDictionary *parameters;
        if (self.lastBeacon == nil)
            parameters = [[NSMutableDictionary alloc] init];
        else
        {
            parameters = [[NSMutableDictionary alloc] init];
            [parameters setValue:self.lastBeacon forKey:@"channel"];
        }
        
        //to be taken out
        NSLog (@"calling unsubscribe with params %@", parameters);
        
        
        [self postPath:@"subscription/unsubscribe/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (error) NSLog(@" %@",error);
        }];
    }
}



#pragma mark Promotions
/////////////////////////////////////////////////////////////////
/*
 * Methods related to promotions
 */
/////////////////////////////////////////////////////////////////


/**
 * Method which retrieves the promotions associated to a beacon
 */

- (void)getPromotionsWithBeaconId:(NSString*) beaconId  onCompletion:(beaconPromotionBlock)completion
{
    
    NSString* major = @"";
    NSString* minor = @"";
    
    major = [beaconId substringToIndex:5];
    minor = [beaconId substringFromIndex:5];
    
    NSString* path = @"";
    path = [NSString stringWithFormat:@"communication/?major=%@&minor=%@", major, minor];
    
    NSLog (@"path is %@ ", path);
    
    [self getPath:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              //to be taken out
              NSLog (@"Reply is %@ ", responseObject);
              
              NVBBeacon* beacon = [NVBBeacon beaconWithDictionary:responseObject];
              
              completion(beacon,nil);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (error.localizedRecoverySuggestion)
              {
                  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[error.userInfo valueForKey:@"NSLocalizedRecoverySuggestion"]dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                  
                  if (dictionary)
                  {
                      if ([dictionary valueForKey:@"error_message"])
                      {
                          if(completion)completion(nil,[dictionary valueForKey:@"error_message"]);
                          return;
                      }
                  }
              }
              
              if(completion)completion(nil,@"There was an error communicating with the server");
              if (error) NSLog(@" %@",error);
              
          }];
    
}


-(void) notifyCommunicationAPI:(NVBBeaconPromotion*) promotion andBeacon:(NVBBeacon*)beacon andParam:(NSString*) param andState:(NSString*) state onCompletion:(booleanSuccessBlock) completionBlock
{
    NSDictionary *parameters = @{
                                 param:state,
                                 @"major" : [NSString stringWithFormat:@"%d",[beacon.major integerValue]],
                                 @"minor" : [NSString stringWithFormat:@"%d",[beacon.minor integerValue]],
                                 
                                 };
    
    [self postPath:[NSString stringWithFormat:@"communication/%@/displayed/", promotion.id] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completionBlock (YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.localizedRecoverySuggestion)
        {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[[error.userInfo valueForKey:@"NSLocalizedRecoverySuggestion"]dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            
            if (dictionary)
            {
                if ([dictionary valueForKey:@"error_message"])
                {
                    if(completionBlock)completionBlock(nil,[dictionary valueForKey:@"error_message"]);
                    return;
                }
            }
        }
        
        if(completionBlock)completionBlock(nil,@"There was an error communicating with the server");
        if (error) NSLog(@" %@",error);
        
    }];
}



@end
