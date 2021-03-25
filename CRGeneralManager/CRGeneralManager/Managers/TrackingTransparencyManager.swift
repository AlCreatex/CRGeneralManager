import Foundation
import AppTrackingTransparency
import AdSupport
import FBSDKCoreKit.FBSDKSettings
import AppsFlyerLib
import FirebaseCore
import FirebaseRemoteConfig

open class TrackingTransparencyManager: NSObject {

    //MARK: - Properties
    fileprivate var remoteCheck: Bool = false
    fileprivate var completion: CompletionBlock?

    //MARK: - Setups
    public func configuration(isStartFirebase: Bool = true, startScreen: CompletionBlock? = nil) {

        self.setupFirebase(isStart: isStartFirebase)
        self.setupATT()
        
        self.completion = { startScreen?() }
    }
    
    //MARK: - Firebase
    fileprivate func setupFirebase(isStart: Bool = true) {
        
        if isStart {
            let firebase = FirebaseSerivce()
            firebase.configuration()
            self.remoteCheck = firebase.remoteConfig.configValue(forKey: "iOSCheck").boolValue
        }
    }

    //MARK: - AppsFlyer
    fileprivate func setupAppsFlyer() {

        let appsFlyer = AppsFlyerService()
        appsFlyer.configuration()
        appsFlyer.additionalCodeAtAnswerAppsFlyer = { [weak self] (data) in
            guard let self = self else { return }
            
            if data["af_status"] as! String == "Organic" && self.remoteCheck {
                self.setupAlertATT()
            }
        }
    }

    //MARK: - ATT
    fileprivate func setupATT() {

        let idfa = ASIdentifierManager.shared().advertisingIdentifier.description
        print(idfa)

        if self.remoteCheck {

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
                if !self.remoteCheck {
                    self.setupAppsFlyer()
                    self.completion?()
                }
            }
        }
    }
}

