import Foundation

public struct UserDefaultsProperties {
    
    //MARK: - Enum
    fileprivate enum NameKeyUserDefault {
        case expiryDate, isStartNowAppsFlyer
        
        fileprivate var key: String {
            switch self {
            case .expiryDate:
                return "StoreManagerExpiryDate"
            case .isStartNowAppsFlyer:
                return "IsStartNowAppsFlyer"
            }
        }
    }
    
    //MARK: - Properties
    internal static var expiryDate: Date? {
        get {
            return UserDefaults.standard.value(forKey: NameKeyUserDefault.expiryDate.key) as? Date
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: NameKeyUserDefault.expiryDate.key)
        }
    }
    
    public static var isStartNowAppsFlyer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: NameKeyUserDefault.isStartNowAppsFlyer.key)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: NameKeyUserDefault.isStartNowAppsFlyer.key)
        }
    }
}
