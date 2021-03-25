import Foundation
import YandexMobileMetrica
import GoogleMobileAds
import StoreKit
import FBSDKCoreKit
import iAd

public class AppManager: NSObject {

    //MARK: - Methods
    public func configuration(application: UIApplication,
                              launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                              userAcquisitionServer: UserAcquisition.Url = .inapps) {
        
        FacebookService().configuration(launchOptions: launchOptions)
        SearchAdsService().configuration()
        YandexService().configuration()
        
        UserAcquisition.shared.configure(withAPIKey: GettingsKeysFromPlist.getKey(by: .userAcquisitionKey) as! String,
                                         urlRequest: userAcquisitionServer)
        UserAcquisition.shared.conversionInfo.fbAnonymousId = AppEvents.anonymousID
        
        StoreManager.shared.configuration()
        SKAdNetwork.registerAppForAdNetworkAttribution()
    }
}

