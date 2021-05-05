import NVActivityIndicatorView

public protocol ActivityIndicatorProtocol {
    
    //MARK: - Properties
    var activityIndicator: NVActivityIndicatorView? { get set }
    
    //MARK: - Functions
    func setupActivityIndicator()
}

extension ActivityIndicatorProtocol where Self: UIViewController {
    
    public var activityIndicator: NVActivityIndicatorView? {
        return self.view.subviews.filter({ ($0 as? NVActivityIndicatorView) != nil }).first as? NVActivityIndicatorView
    }
    
    public func setupActivityIndicator(type: NVActivityIndicatorType) {
        
        let indicator = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: type, color: .HEX_FFFFFF)
        indicator.backgroundColor = .HEX_000000_70
        indicator.padding = (UIScreen.main.bounds.width / 2.5) * Constants.Interface.sizeScale
        self.view.addSubview(indicator)
    }
}
