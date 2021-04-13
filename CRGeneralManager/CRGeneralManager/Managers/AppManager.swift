import Foundation
import YandexMobileMetrica
import StoreKit
import FBSDKCoreKit
import iAd

open class AppManager: NSObject {

    //MARK: - Methods
    public func configuration(application: UIApplication,
                              launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                              userAcquisitionServer: UserAcquisitionManager.Url = .inapps,
                              configurationGoogleAds: Bool = false) {
        
        FacebookService().configuration(launchOptions: launchOptions)
        SearchAdsService().configuration()
        YandexService().configuration()
        
        UserAcquisitionManager.shared.configure(withAPIKey: GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                                                         by: .userAcquisitionKey) as? String ?? "",
                                         urlRequest: userAcquisitionServer)
        UserAcquisitionManager.shared.conversionInfo.fbAnonymousId = AppEvents.anonymousID
        
        StoreManager.shared.configuration()
        if configurationGoogleAds {
            GoogleAdsManager.shared.configuration()
        }
        SKAdNetwork.registerAppForAdNetworkAttribution()
    }
}

