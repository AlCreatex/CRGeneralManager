import Foundation
import YandexMobileMetrica
import GoogleMobileAds
import StoreKit
import FBSDKCoreKit
import iAd

final class AppManager: NSObject {

    //MARK: - Methods
    public func configuration(application: UIApplication,
                              launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                              userAcquisitionServer: UserAcquisitionManager.Url = .inapps) {
        
        FacebookService().configuration(launchOptions: launchOptions)
        SearchAdsService().configuration()
        YandexService().configuration()
        
        UserAcquisitionManager.shared.configure(withAPIKey: GettingsKeysFromPlist.getKey(by: .userAcquisitionKey) as? String ?? "",
                                         urlRequest: userAcquisitionServer)
        UserAcquisitionManager.shared.conversionInfo.fbAnonymousId = AppEvents.anonymousID
        
        StoreManager.shared.configuration()
        SKAdNetwork.registerAppForAdNetworkAttribution()
    }
}

