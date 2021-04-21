import Foundation
import GoogleMobileAds

open class GoogleAdsManager: NSObject {
    
    //MARK: - Singleton
    public static let shared = GoogleAdsManager()
    
    //MARK: - Properties
    fileprivate var interWorkItem: DispatchWorkItem?
    fileprivate var interQueue: DispatchQueue = .init(label: Constants.NameQueue.intersititalTimeOutQueue,
                                                      qos: .background,
                                                      attributes: .concurrent,
                                                      autoreleaseFrequency: .never,
                                                      target: nil)
    
    
    fileprivate var rewardWorkItem: DispatchWorkItem?
    fileprivate var rewardQueue: DispatchQueue = .init(label: Constants.NameQueue.rewardedTimeOutQueue,
                                                       qos: .background,
                                                       attributes: .concurrent,
                                                       autoreleaseFrequency: .never,
                                                       target: nil)
    
    fileprivate var completionFullScreenContent: CompletionBlock?
    fileprivate var timeReloadRequest: Double = 60.0
    
    fileprivate var interstitialKey: String?
    fileprivate var interstitial: GADInterstitialAd?
    
    fileprivate var bannerKey: String?
    
    fileprivate var rewardedKey: String?
    fileprivate var rewarded: GADRewardedAd?
    
    //MARK: - Configuration
    public func configuration() {
        
        self.getKeysFromPlist()
        self.loadInterstitial()
        self.loadRewarded()
    }
    
    //MARK: - Get keys from plist
    fileprivate func getKeysFromPlist() {
        
        self.interstitialKey = GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                            by: .interstitialKey) as? String
        self.bannerKey = GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                      by: .bannerKey) as? String
        self.rewardedKey = GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                        by: .rewardedKey) as? String
    }
    
    //MARK: - Interstitial
    public func presentInterstitial(viewController: UIViewController, completion: CompletionBlock?) {
        
        if !StoreManager.shared.isActive {
            if let interstitial = self.interstitial {
                interstitial.present(fromRootViewController: viewController)
            } else {
                AnalyticsManager.trackWith(eventName: .interstitialAdWasntReady)
                completion?()
            }
            
            self.reloadInterstitialRequest()
            self.completionFullScreenContent = {
                self.interstitial = nil
                completion?()
            }
        }
    }
    
    fileprivate func loadInterstitial() {
        
        guard let interstitialKey = self.interstitialKey else { return }
        let interstitialRequest = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: interstitialKey,
                               request: interstitialRequest) { (ad, error) in
            
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                AnalyticsManager.trackWith(eventName: .interstitialLoadingError)
                self.reloadInterstitialRequest()
                self.completionFullScreenContent?()
                return
            }
            
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    fileprivate func reloadInterstitialRequest() {
        
        if self.interWorkItem == nil {
            self.interWorkItem = DispatchWorkItem(qos: .default) {
                self.loadInterstitial()
                self.interWorkItem = nil
            }
            
            self.interQueue.asyncAfter(deadline: .now() + self.timeReloadRequest, execute: self.interWorkItem!)
        }
    }
    
    //MARK: - Banner
    public func present(bannerView: GADBannerView, viewController: UIViewController) {
        
        if !StoreManager.shared.isActive {
            bannerView.adUnitID = bannerKey
            bannerView.rootViewController = viewController
            bannerView.delegate = self
            bannerView.load(GADRequest())
        }
    }
    
    //MARK: - Rewarded
    public func presentRewarded(viewController: UIViewController,
                                completion: CompletionBlock?,
                                userDidEarnRewardHandler: @escaping GADUserDidEarnRewardHandler) {
        
        if !StoreManager.shared.isActive {
            if let rewarded = self.rewarded {
                rewarded.present(fromRootViewController: viewController,
                                 userDidEarnRewardHandler: userDidEarnRewardHandler)
            } else {
                AnalyticsManager.trackWith(eventName: .rewardAdWasntReady)
                completion?()
            }
            
            self.reloadRewardedRequest()
            self.completionFullScreenContent = {
                self.rewarded = nil
                completion?()
            }
        }
    }
    
    fileprivate func loadRewarded() {
        
        guard let rewardedKey = self.rewardedKey else { return }
        let rewardedRequest = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: rewardedKey,
                           request: rewardedRequest) { (ad, error) in
            
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                AnalyticsManager.trackWith(eventName: .rewardLoadingError)
                self.reloadRewardedRequest()
                self.completionFullScreenContent?()
                return
            }
            
            self.rewarded = ad
            self.rewarded?.fullScreenContentDelegate = self
        }
    }
    
    fileprivate func reloadRewardedRequest() {
        
        if self.rewardWorkItem == nil {
            self.rewardWorkItem = DispatchWorkItem(qos: .default) {
                self.loadRewarded()
                self.rewardWorkItem = nil
            }
            
            self.rewardQueue.asyncAfter(deadline: .now() + self.timeReloadRequest, execute: self.rewardWorkItem!)
        }
    }
}

//MARK: - GADFullScreenContentDelegate
extension GoogleAdsManager: GADFullScreenContentDelegate {
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.reloadInterstitialRequest()
        self.reloadRewardedRequest()
        self.completionFullScreenContent?()
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.reloadInterstitialRequest()
        self.reloadRewardedRequest()
        self.completionFullScreenContent?()
    }
}

//MARK: - GADBannerViewDelegate
extension GoogleAdsManager: GADBannerViewDelegate {
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        AnalyticsManager.trackWith(eventName: .bannerLoadingError)
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDismissScreen")
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
