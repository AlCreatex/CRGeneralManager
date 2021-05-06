import Foundation
import AppTrackingTransparency
import AdSupport
import FBSDKCoreKit.FBSDKSettings
import AppsFlyerLib

open class TrackingTransparencyManager: NSObject {

    //MARK: - Singleton
    public static let shared = TrackingTransparencyManager()
    
    //MARK: - Properties
    fileprivate var idfaExist: Bool {
        get {
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.description
            print(idfa)
            return idfa != "00000000-0000-0000-0000-000000000000"
        }
    }

    //MARK: - Setups
    public func configuration() {

        if self.idfaExist {
            AppsFlyerService().configuration()
        } else {
            self.setupFirstLaunchATT()
        }
    }

    fileprivate func setupFirstLaunchATT() {

        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { (state) in
                switch state {
                case .denied:
                    FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(false)
                    AnalyticsManager.trackWith(eventName: .idfaDisallowed)
                case .authorized:
                    FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(true)
                    AnalyticsManager.trackWith(eventName: .idfaAllowed)
                default:
                    break
                }
                
                AppsFlyerService().configuration()
            }
        } else {
            AppsFlyerService().configuration()
        }
    }
    
    public func setupInsideAppATT() {

        if #available(iOS 14.0, *) {
            if !UserDefaultsProperties.isStartNowAppsFlyer && self.idfaExist {
                ATTrackingManager.requestTrackingAuthorization { (state) in
                    switch state {
                    case .denied:
                        FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(false)
                        AnalyticsManager.trackWith(eventName: .idfaDisallowed)
                    case .authorized:
                        FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(true)
                        AnalyticsManager.trackWith(eventName: .idfaAllowed)
                    default:
                        break
                    }
                }
            }
        }
    }
}

