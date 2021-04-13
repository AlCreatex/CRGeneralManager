import UIKit
import DeviceKit

public struct Constants {
    
    internal struct NameUserDefaults {
        static let storeManagerExpiryDate   = "StoreManagerExpiryDate"
        static let isStartNowAppsFlyer      = "IsStartNowAppsFlyer"
    }
    
    internal struct NameQueue {
        static let intersititalTimeOutQueue = "com.google.interstitial.queue"
        static let rewardedTimeOutQueue     = "com.google.rewarded.queue"
    }
    
    internal struct NameAtInfoPlist {
        static let appVersion    = "CFBundleShortVersionString"
        static let bundleVersion = "CFBundleVersion"
    }
    
    internal struct NameAtKeysPlist {
        static let appID                = "AppID"
        static let sharedKey            = "SharedKey"
        static let yandexKey            = "YandexKey"
        static let facebookKey          = "FacebookKey"
        static let appsFlyerKey         = "AppsFlyerKey"
        static let userAcquisitionKey   = "UserAcquisitionKey"
        static let intersititalKey      = "IntersititalKey"
        static let bannerKey            = "BannerKey"
        static let rewardedKey          = "RewardedKey"
    }
    
    internal struct NameFile {
        static let remoteConfig = "RemoteConfigPlist"
        static let product = "ProductPlist"
    }
    
    internal struct TypeFile {
        static let plist = "plist"
    }
    
    public struct Interface {
        public static let sizeScale: CGFloat = Device.current.isPhone ? UIScreen.main.bounds.height / (Device.current.diagonal <= Device.iPhone8Plus.diagonal ? 736.0 : 812.0) : 1.0
    }
}
