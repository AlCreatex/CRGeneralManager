import Foundation
import AppTrackingTransparency
import AdSupport
import FBSDKCoreKit.FBSDKSettings
import AppsFlyerLib
import FirebaseCore
import FirebaseRemoteConfig

open class TrackingTransparencyManager: NSObject {

    //MARK: - Properties
    fileprivate var completion: CompletionBlock?

    //MARK: - Setups
    public func configuration(isStartFirebase: Bool = true,
                              isStartRemoteConfig: Bool = true,
                              startScreen: CompletionBlock? = nil) {

        self.completion = { startScreen?() }
        self.setupFirebase(isStartFirebase: isStartFirebase, isStartRemoteConfig: isStartRemoteConfig)
        self.setupATT()
    }
    
    //MARK: - Firebase
    fileprivate func setupFirebase(isStartFirebase: Bool, isStartRemoteConfig: Bool) {
        
        FirebaseSerivce().configuration(isStartFirebase: isStartFirebase,
                                        isStartRemoteConfig: isStartRemoteConfig)
    }

    //MARK: - AppsFlyer
    fileprivate func setupAppsFlyer() {

        AppsFlyerService.shared.configuration()
        AppsFlyerService.shared.additionalCodeAtAnswerAppsFlyer = { [weak self] (data) in
            guard let self = self else { return }
            
            if data["af_status"] as! String == "Organic" && UserDefaultsProperties.iOSCheck {
                self.setupAlertATT()
            }
        }
    }

    //MARK: - ATT
    fileprivate func setupATT() {

        let idfa = ASIdentifierManager.shared().advertisingIdentifier.description
        print("IDFA: \(idfa)")

        if UserDefaultsProperties.iOSCheck {

            AnalyticsManager.trackWith(eventName: .init(rawValue: "StartCheck_With_iOS_14.4_13"))
            self.setupAppsFlyer()
            self.completion?()
        } else {

            AnalyticsManager.trackWith(eventName: .init(rawValue: "StartCheck_With_iOS_14.0_14.5"))
            if #available(iOS 14.0, *) {
                self.setupAlertATT()
            } else {
                self.setupAppsFlyer()
                self.completion?()
            }
        }
    }

    fileprivate func setupAlertATT() {

        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { (state) in
                switch state {
                case .denied:
                    AnalyticsManager.trackWith(eventName: .init(rawValue: "idfa_disallowed"))
                case .authorized:
                    AnalyticsManager.trackWith(eventName: .init(rawValue: "idfa_allowed"))
                default:
                    break
                }

                FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(true)
                if !UserDefaultsProperties.iOSCheck {
                    self.setupAppsFlyer()
                    self.completion?()
                }
            }
        }
    }
}

