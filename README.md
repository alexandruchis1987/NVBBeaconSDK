## Usage

## Requirements

iOS8+

## Installation

NVBBeaconSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NVBBeaconSDK"
```

## Credentials

1. Log in the dashboard [http://admin.invibe.me/](http://admin.invibe.me/) with your credentials

2. Navigate on the left to the applications area

3. Take a look at the client id and client secret, you will need them later

###Application Delegate file 

In the import section add

```ruby
#import <NVBBeaconSDK/NVBBeaconSDK.h>
```


###If your app already has push notifications enabled you can go on, otherwise check [How To Configure Push Notifications](https://github.com/alexandruchis1987/NVBBeaconSDK/wiki/Push-Notifications)


Before the last line of ‘didFinishLaunchingWithOptions’ method request push notification authorization

```ruby
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//Register to receive push notifications
#ifdef __IPHONE_8_0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

#endif

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    
    return YES;
}
```

Start the Beacon SDK services

```ruby
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//Register to receive push notifications
#ifdef __IPHONE_8_0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
#endif

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    
    
    [NVBBeaconSDK setApplicationIdentifier:@“YOUR_APPLICATION_KEY”];
    [NVBBeaconSDK startServices];
    
    
    return YES;
}
```

Forward push notifications method calls to the Beacon SDK

```ruby
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (deviceToken)
    {
        NSLog (@"Successfully registered for remote notifications");
        [NVBBeaconSDK didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        NSLog(@"Failed to register for remote notifications %@", error);
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    //Forward the call to the beacon sdk as well
    [NVBBeaconSDK didReceiveRemoteNotification:userInfo];
}


-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //Forward the call to the beacon sdk as well
    [NVBBeaconSDK didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    
}
```




## Author

Alexandru Chis, alexandru.chis1987@gmail.com

## License

NVBBeaconSDK is available under the MIT license. See the LICENSE file for more info.
=======
=======
# NVBBeaconSDK
