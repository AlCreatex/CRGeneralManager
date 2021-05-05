import NVActivityIndicatorView

public protocol ActivityIndicatorProtocol {
    func setupActivityIndicator(type: NVActivityIndicatorType)
    func startAnimation()
    func stopAnimation()
}

extension ActivityIndicatorProtocol where Self: UIViewController {
    
    fileprivate var activityIndicator: NVActivityIndicatorView? {
        return self.view.subviews.filter({ ($0 as? NVActivityIndicatorView) != nil }).first as? NVActivityIndicatorView
    }
    
    public func setupActivityIndicator(type: NVActivityIndicatorType) {
        
        let indicator = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: type, color: .HEX_FFFFFF)
        indicator.backgroundColor = .HEX_000000_70
        indicator.padding = (UIScreen.main.bounds.width / 2.5) * Constants.Interface.sizeScale
        self.view.addSubview(indicator)
    }
    
    public func startAnimation() {
        
        self.activityIndicator?.startAnimating()
    }
    
    public func stopAnimation() {
        
        self.activityIndicator?.stopAnimating()
    }
}
