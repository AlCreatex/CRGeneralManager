import NVActivityIndicatorView

internal protocol ActivityIndicatorProtocol {
    
    //MARK: - Properties
    var activityIndicator: NVActivityIndicatorView? { get set }
    
    //MARK: - Functions
    func setupActivityIndicator()
}

extension ActivityIndicatorProtocol where Self: UIViewController {
    
    internal var activityIndicator: NVActivityIndicatorView? {
        return self.view.subviews.filter({ ($0 as? NVActivityIndicatorView) != nil }).first as? NVActivityIndicatorView
    }
    
    internal func setupActivityIndicator(type: NVActivityIndicatorType) {
        
        let indicator = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: type, color: .HEX_FFFFFF)
        indicator.backgroundColor = .HEX_000000_70
        indicator.padding = (UIScreen.main.bounds.width / 2.5) * Constants.Interface.sizeScale
        self.view.addSubview(indicator)
    }
}
