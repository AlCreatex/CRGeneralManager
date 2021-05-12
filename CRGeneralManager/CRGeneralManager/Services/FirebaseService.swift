import FirebaseCore

open class FirebaseSerivce: NSObject {
    
    //MARK: - Properties
    
    //MARK: - Configuration
    public func configuration(isLaunchFirebase: Bool = true) {
        
        if isLaunchFirebase {
            
            FirebaseApp.configure()
        }
    }
}
