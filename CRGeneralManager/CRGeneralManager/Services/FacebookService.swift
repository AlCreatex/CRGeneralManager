import FBSDKCoreKit

final class FacebookService: NSObject {
    
    //MARK: - Configuration
    public func configuration(launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                    autoLogEventsEnabled: Bool = false,
                                    advertiserIDCollectionEnabled: Bool = true) {
        
        ApplicationDelegate.initializeSDK(launchOptions)
        AppEvents.activateApp()
        FBSDKCoreKit.Settings.appID = GettingsKeysFromPlist.getKey(by: .facebookKey) as? String
        FBSDKCoreKit.Settings.isAutoLogAppEventsEnabled = autoLogEventsEnabled
        FBSDKCoreKit.Settings.isAdvertiserIDCollectionEnabled = advertiserIDCollectionEnabled
    }
}
