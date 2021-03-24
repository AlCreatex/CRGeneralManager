import Foundation
import GoogleMobileAds

final class GoogleAdsManager: NSObject {
    
    //MARK: - Singleton
    public static let shared = GoogleAdsManager()
    
    //MARK: - Properties
    fileprivate var interQueue: DispatchQueue = .init(label: Constants.NameQueue.intersititalTimeOutQueue,
                                                      qos: .default,
                                                      attributes: .concurrent,
                                                      autoreleaseFrequency: .never,
                                                      target: nil)
    fileprivate var workItem: DispatchWorkItem?
    
    fileprivate var timeReloadRequest: Double = 30.0
    fileprivate var completionInterstitial: CompletionBlock?
    
    fileprivate var interstitialKey: String?
    fileprivate var interstitial: GADInterstitialAd?
    
    //MARK: - Configuration
    public func configuration() {
        
        self.getKeysFromPlist()
        self.loadInterstitial()
    }
    
    //MARK: - Get keys from plist
    fileprivate func getKeysFromPlist() {
        
        self.interstitialKey = GettingsKeysFromPlist.getKey(by: .interstitialKey) as? String
    }
    
    //MARK: - Interstitial
    public func presentInterstitial(viewController: UIViewController, completion: CompletionBlock?) {
        
        if let interstitial = self.interstitial {
            interstitial.present(fromRootViewController: viewController)
        } else {
            print("Ad wasn't ready")
            completion?()
        }
        
        self.reloadLoadRequest()
        self.completionInterstitial = {
            self.interstitial = nil
            completion?()
        }
    }
    
    fileprivate func loadInterstitial() {
        
        guard let interstitialKey = self.interstitialKey else { return }
        let interstitialRequest = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: interstitialKey,
                               request: interstitialRequest) { (ad, error) in
            
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                self.reloadLoadRequest()
                self.completionInterstitial?()
                return
            }
            
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    fileprivate func reloadLoadRequest() {
        
        if self.workItem == nil {
            self.workItem = DispatchWorkItem(qos: .default) {
                self.loadInterstitial()
                self.workItem = nil
            }
            
            self.interQueue.asyncAfter(deadline: .now() + self.timeReloadRequest, execute: self.workItem!)
        }
    }
}

//MARK: - GADFullScreenContentDelegate
extension GoogleAdsManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.reloadLoadRequest()
        self.completionInterstitial?()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.reloadLoadRequest()
        self.completionInterstitial?()
    }
}
