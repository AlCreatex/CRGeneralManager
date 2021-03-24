import iAd
import UserAcquisition

final class SearchAdsService: NSObject {
    
    //MARK: - Configuration
    public func configuration() {
        
        ADClient.shared().requestAttributionDetails { (attributed, error) in
            guard let attributed = attributed else {
                print("SearchAds error: \(error?.localizedDescription ?? "")")
                return
            }
            
            UserAcquisition.shared.conversionInfo.setSearchAds(attributed)
        }
    }
}
