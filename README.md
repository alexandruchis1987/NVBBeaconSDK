## Usage

## Requirements

iOS8+

## Installation

NVBBeaconSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NVBBeaconSDK"
```

###Application Delegate file 

In the import section add

```ruby
#import <NVBBeaconSDK/NVBBeaconSDK.h>
```

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


## Author

Alexandru Chis, alexandru.chis1987@gmail.com

## License

NVBBeaconSDK is available under the MIT license. See the LICENSE file for more info.
=======
=======
# NVBBeaconSDK
