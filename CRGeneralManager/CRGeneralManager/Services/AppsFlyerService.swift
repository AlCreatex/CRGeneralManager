import AppsFlyerLib

final class AppsFlyerService: NSObject {
    
    //MARK: - Properties
    public var additionalCodeAtAnswerAppsFlyer: CompletionBlockAppsFlyer?
    
    //MARK: - Configaration
    public func configuration() {
        
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().appsFlyerDevKey = GettingsKeysFromPlist.getKey(by: .appsFlyerKey) as! String
        AppsFlyerLib.shared().appleAppID = GettingsKeysFromPlist.getKey(by: .appID) as! String
        AppsFlyerLib.shared().start()
    }
}

//MARK: - AppsFlyerLibDelegate
extension AppsFlyerService: AppsFlyerLibDelegate {

    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {

        if let data = conversionInfo as? [String: Any] {

            AnalyticsManager.trackWith(eventName: .init(rawValue: "AppsFlyer_Data"), parameters: data)

            if data["af_status"] as! String != "Organic" && !UserDefaultsProperties.isStartNowAppsFlyer {
                UserDefaultsProperties.isStartNowAppsFlyer = true
            }

            self.additionalCodeAtAnswerAppsFlyer?(data)

            UserAcquisition.shared.conversionInfo.setAppsFlyerData(data)
            UserAcquisition.shared.conversionInfo.appsFlyerId = AppsFlyerLib.shared().getAppsFlyerUID()
        } else {
            
            AnalyticsManager.trackWith(eventName: .init(rawValue: "AppsFlyer_ErrorData"), parameters: conversionInfo)
        }
    }

    func onConversionDataFail(_ error: Error) { }

    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) { }
}
