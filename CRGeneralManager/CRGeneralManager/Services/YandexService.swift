import YandexMobileMetrica
import CRSupportManager

open class YandexService: NSObject {
    
    //MARK: - Configuration
    public func configuration() {
        
        if let apiKey = GettingsKeysFromPlist.getKey(from: .remoteConfig,
                                                     by: .yandexKey) as? String,
           let configYandex = YMMYandexMetricaConfiguration.init(apiKey: apiKey) {
            YMMYandexMetrica.activate(with: configYandex)
        }
    }
}
