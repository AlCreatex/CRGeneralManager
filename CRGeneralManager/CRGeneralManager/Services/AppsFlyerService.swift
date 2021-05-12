import AppsFlyerLib
import CRSupportManager

open class AppsFlyerService: NSObject {

    //MARK: - Properties
    public var additionalCodeAtAnswerAppsFlyer: CompletionBlockAppsFlyer?
    
    //MARK: - Configaration
    public func configuration() {
        
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().appsFlyerDevKey = GettingsKeysFromPlist.getKey(from: .remoteConfig,
                                                                             by: .appsFlyerKey) as? String ?? ""
        AppsFlyerLib.shared().appleAppID = GettingsKeysFromPlist.getKey(from: .remoteConfig,
                                                                        by: .appID) as? String ?? ""
        AppsFlyerLib.shared().start()
    }
}

//MARK: - AppsFlyerLibDelegate
extension AppsFlyerService: AppsFlyerLibDelegate {

    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {

        if let data = conversionInfo as? [String: Any] {

            AnalyticsManager.trackWith(eventName: .appsFlyerData, parameters: data)

            if data["af_status"] as! String != "Organic" && !UserDefaultsProperties.isStartNowAppsFlyer {
                UserDefaultsProperties.isStartNowAppsFlyer = true
            }

            self.additionalCodeAtAnswerAppsFlyer?(data)

            UserAcquisitionManager.shared.conversionInfo.setAppsFlyerData(data)
            UserAcquisitionManager.shared.conversionInfo.appsFlyerId = AppsFlyerLib.shared().getAppsFlyerUID()
        } else {
            
            AnalyticsManager.trackWith(eventName: .appsFlyerErrorData, parameters: conversionInfo)
        }
    }

    public func onConversionDataFail(_ error: Error) { }

    public func onConversionDataReceived(_ installData: [AnyHashable : Any]!) { }
}
