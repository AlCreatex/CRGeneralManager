import Foundation
import FirebaseRemoteConfig

public struct UserDefaultsProperties {
    
    internal static var expiryDate: Date? {
        get {
            return UserDefaults.standard.value(forKey: Constants.NameUserDefaults.storeManagerExpiryDate) as? Date
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.NameUserDefaults.storeManagerExpiryDate)
        }
    }
    
    public static var isStartNowAppsFlyer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.NameUserDefaults.isStartNowAppsFlyer)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.NameUserDefaults.isStartNowAppsFlyer)
        }
    }
    
    public static var iOSCheck: Bool {
        get {
            return RemoteConfig.remoteConfig().configValue(forKey: "iOSCheck").boolValue
        }
    }
}
