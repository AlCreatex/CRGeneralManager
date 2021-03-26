import Foundation

final class GettingsKeysFromPlist: NSObject {
    
    //MARK: - Enum prepare properties
    public struct Keys {
        
        public var rawValue: String
        
        public static let appID                 = Keys(rawValue: Constants.NameAtKeysPlist.appID)
        public static let sharedKey             = Keys(rawValue: Constants.NameAtKeysPlist.sharedKey)
        public static let yandexKey             = Keys(rawValue: Constants.NameAtKeysPlist.yandexKey)
        public static let facebookKey           = Keys(rawValue: Constants.NameAtKeysPlist.facebookKey)
        public static let appsFlyerKey          = Keys(rawValue: Constants.NameAtKeysPlist.appsFlyerKey)
        public static let userAcquisitionKey    = Keys(rawValue: Constants.NameAtKeysPlist.userAcquisitionKey)
        public static let interstitialKey       = Keys(rawValue: Constants.NameAtKeysPlist.intersititalKey)
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    //MARK: - Get key from plist
    static public func getKey(from file: String, by value: Keys) -> Any? {
        
        guard let path = Bundle.main.path(forResource: file, ofType: Constants.TypeFile.plist) else {
            print("Failed to get path to \(file)")
            return nil
        }
        
        let keys = NSDictionary(contentsOfFile: path)
        if let value = keys?[value.rawValue] {
            return value
        } else {
            print("Failed to get (\(value.rawValue)) from \(file)")
            return nil
        }
    }
    
    static public func getAllKeys(from file: String) -> NSDictionary? {
        
        guard let path = Bundle.main.path(forResource: file, ofType: Constants.TypeFile.plist) else {
            print("Failed to get path to \(file)")
            return nil
        }
        
        let keys = NSDictionary(contentsOfFile: path)
        guard let verifiedKeys = keys else {
            return nil
        }
        
        return verifiedKeys
    }
}
