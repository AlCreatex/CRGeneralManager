import Foundation
import YandexMobileMetrica
import FBSDKCoreKit
import FirebaseAnalytics
import AppsFlyerLib
import CRSupportManager

open class AnalyticsManager: NSObject {
    
    //MARK: - Enum
    fileprivate enum NameAtInfoPlist: String {
        case appVersion, bundleVersion
        
        fileprivate var key: String {
            switch self {
            case .appVersion:
                return "CFBundleShortVersionString"
            case .bundleVersion:
                return "CFBundleVersion"
            }
        }
    }
    
    //MARK: - Struct enum
    public struct EventName {
        
        public var rawValue: String
        
        internal static let subscriptionDone            = EventName(rawValue: "Subscription_Done")
        internal static let subscriptionCancel          = EventName(rawValue: "Subscription_Cancel")
        internal static let subscriptionFailed          = EventName(rawValue: "Subscription_Failed")
        internal static let restoreDone                 = EventName(rawValue: "Restore_Done")
        internal static let restoreFailed               = EventName(rawValue: "Restore_Failed")
        internal static let idfaDisallowed              = EventName(rawValue: "Idfa_Disallowed")
        internal static let idfaAllowed                 = EventName(rawValue: "Idfa_Allowed")
        internal static let appsFlyerData               = EventName(rawValue: "AppsFlyer_Data")
        internal static let appsFlyerErrorData          = EventName(rawValue: "AppsFlyer_ErrorData")
        internal static let remoteConfigNoFetchYet      = EventName(rawValue: "RemoteConfig_NoFetchYet")
        internal static let remoteConfigSuccess         = EventName(rawValue: "RemoteConfig_Success")
        internal static let remoteConfigFailure         = EventName(rawValue: "RemoteConfig_Failure")
        internal static let remoteConfigThrottled       = EventName(rawValue: "RemoteConfig_Throttled")
        internal static let remoteConfigError           = EventName(rawValue: "RemoteConfig_Error")
        internal static let interstitialAdWasntReady    = EventName(rawValue: "Interstitial_AdWasntReady")
        internal static let interstitialLoadingError    = EventName(rawValue: "Interstitial_LoadingError")
        internal static let rewardAdWasntReady          = EventName(rawValue: "Reward_AdWasntReady")
        internal static let rewardLoadingError          = EventName(rawValue: "Reward_LoadingError")
        internal static let bannerLoadingError          = EventName(rawValue: "Banner_LoadingError")
        
        public static let subscribeOrganic              = EventName(rawValue: "Subscribe_Organic")
        public static let startNowAppsFlyer             = EventName(rawValue: "StartNow_AppsFlyer")
        public static let closeOnboarding               = EventName(rawValue: "Close_Onboarding")
        public static let closePremium                  = EventName(rawValue: "Close_Premium")
        
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
        
        print("Analytics EVENT NAME: \(eventName.rawValue), with parameters: \(newParameters)")
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
        
        print("Analytics PURCHASE EVENT NAME: \(eventName.rawValue), price: \(price), currency: \(currency ?? "")")
    }
    
    //MARK: - Additional parameters
    fileprivate static func addititonalParameters(parameters: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        
        var additionalParameters = [AnyHashable: Any]()
        additionalParameters["app_version"] = Bundle.main.infoDictionary?[NameAtInfoPlist.appVersion.key] ?? "AppVersion_Not_Found"
        additionalParameters["app_build"] = Bundle.main.infoDictionary?[NameAtInfoPlist.bundleVersion.key] ?? "AppBuild_Not_Found"
        
        guard var parameters = parameters else {
            return additionalParameters
        }
        
        parameters.merge(additionalParameters) { (current, _) -> Any in current }
        return parameters
    }
}
