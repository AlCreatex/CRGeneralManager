import iAd

final class SearchAdsService: NSObject {
    
    //MARK: - Configuration
    public func configuration() {
        
        ADClient.shared().requestAttributionDetails { (attributed, error) in
            guard let attributed = attributed else {
                print("SearchAds error: \(error?.localizedDescription ?? "")")
                return
            }
            
            UserAcquisitionManager.shared.conversionInfo.setSearchAds(attributed)
        }
    }
}
