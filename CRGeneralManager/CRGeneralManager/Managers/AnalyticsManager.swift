import Foundation
import YandexMobileMetrica
import FBSDKCoreKit
import FirebaseAnalytics
import AppsFlyerLib

open class AnalyticsManager: NSObject {
    
    public struct EventName {
        
        public var rawValue: String
        
        public static let subscribeOrganic      = EventName(rawValue: "Subscribe_Organic")
        public static let startNowAppsFlyer     = EventName(rawValue: "StartNow_AppsFlyer")
        public static let closeOnboarding       = EventName(rawValue: "Close_Onboarding")
        public static let closePremium          = EventName(rawValue: "Close_Premium")
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    //MARK: - Default Events
    static public func trackWith(eventName: EventName, parameters: [AnyHashable: Any]? = nil) {

        let newParameters = self.addititonalParameters(parameters: parameters)
        
        YMMYandexMetrica.reportEvent(eventName.rawValue,
                                     parameters: newParameters,
                                     onFailure: nil)
        
        AppEvents.logEvent(.init(eventName.rawValue),
                           parameters: newParameters as? [String: Any] ?? [:])
        
        Analytics.logEvent(eventName.rawValue,
                           parameters: newParameters as? [String: Any])
        
        AppsFlyerLib.shared().logEvent(eventName.rawValue,
                                       withValues: newParameters)
        
        print("Send event with Name: \(eventName.rawValue), parameters: \(newParameters)")
    }

    //MARK: - Purchase Events
    static public func trackPurchase(eventName: EventName, price: Double, currency: String?) {

        let newParameters = self.addititonalParameters(parameters: ["Price": price,
                                                                    "Currency": currency ?? ""])
        
        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: ["eventValue": ""])
        AppsFlyerLib.shared().logEvent(eventName.rawValue,
                                       withValues: newParameters)

        AppEvents.logPurchase(price, currency: currency ?? "")
        AppEvents.logEvent(.init(eventName.rawValue),
                           parameters: newParameters as? [String: Any] ?? [:])
        
        Analytics.logEvent(eventName.rawValue,
                           parameters: newParameters as? [String: Any])
        
        YMMYandexMetrica.reportEvent(eventName.rawValue,
                                     parameters: newParameters,
                                     onFailure: nil)
        
        print("Send event PURCHASE with Name: \(eventName.rawValue), price: \(price), currency: \(currency ?? "")")
    }
    
    //MARK: - Additional parameters
    fileprivate static func addititonalParameters(parameters: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        
        var additionalParameters = [AnyHashable: Any]()
        additionalParameters["app_version"] = Bundle.main.infoDictionary?[Constants.NameAtInfoPlist.appVersion] ?? "AppVersion_Not_Found"
        additionalParameters["app_build"] = Bundle.main.infoDictionary?[Constants.NameAtInfoPlist.bundleVersion] ?? "AppBuild_Not_Found"
        
        guard var parameters = parameters else {
            return additionalParameters
        }
        
        parameters.merge(additionalParameters) { (current, _) -> Any in current }
        return parameters
    }
}
