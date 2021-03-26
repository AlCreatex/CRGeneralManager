import FirebaseCore
import FirebaseRemoteConfig

open class FirebaseSerivce: NSObject {
    
    //MARK: - Properties
    public var remoteConfig: RemoteConfig!
    
    //MARK: - Configuration
    public func configuration(isStartFirebase: Bool = true, isStartRemoteConfig: Bool = true) {
        
        if isStartFirebase {
            FirebaseApp.configure()
            
            if isStartRemoteConfig {
                self.setupRemoteConfig()
                self.fetchRemoteConfig()
            }
        }
    }
    
    //MARK: - Setup RemoteConfig
    fileprivate func setupRemoteConfig() {
        
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = 2
        
        self.remoteConfig.configSettings = settings
        self.remoteConfig.setDefaults(fromPlist: Constants.NameFile.remoteConfig)
    }
    
    fileprivate func fetchRemoteConfig() {
        
        self.remoteConfig.fetch { (status, error) in
            switch status {
            case .noFetchYet:
                AnalyticsManager.trackWith(eventName: .init(rawValue: "RemoteConfig_NoFetchYet"))
            case .success:
                AnalyticsManager.trackWith(eventName: .init(rawValue: "RemoteConfig_Success"))
            case .failure:
                AnalyticsManager.trackWith(eventName: .init(rawValue: "RemoteConfig_Failure"))
            case .throttled:
                AnalyticsManager.trackWith(eventName: .init(rawValue: "RemoteConfig_Throttled"))
            @unknown default:
                break
            }
            
            if let error = error {
                AnalyticsManager.trackWith(eventName: .init(rawValue: "RemoteConfig_Error: \(error.localizedDescription)"))
            }
        }
    }
}
