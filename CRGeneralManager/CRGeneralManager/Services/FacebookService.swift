import FBSDKCoreKit

open class FacebookService: NSObject {
    
    //MARK: - Configuration
    public func configuration(autoLogEventsEnabled: Bool = false,
                              advertiserIDCollectionEnabled: Bool = true) {
        
        AppEvents.activateApp()
        FBSDKCoreKit.Settings.appID = GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                                   by: .facebookKey) as? String
        FBSDKCoreKit.Settings.isAutoLogAppEventsEnabled = autoLogEventsEnabled
        FBSDKCoreKit.Settings.isAdvertiserIDCollectionEnabled = advertiserIDCollectionEnabled
    }
}
