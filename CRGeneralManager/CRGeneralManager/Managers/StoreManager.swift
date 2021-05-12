import SwiftyStoreKit
import CRSupportManager

open class StoreManager: NSObject {

    public enum PurchaseState {
        case successful, failed, cancelled
    }
    
    public enum RestoreState {
        case successful, failed
    }
    
    //MARK: - Singleton
    public static let shared = StoreManager()
    
    //MARK: - Properties
    fileprivate var products = Set<String>()
    fileprivate let sharedKey = GettingsKeysFromPlist.getKey(from: .remoteConfig,
                                                             by: .sharedKey) as? String ?? ""
    fileprivate var isTestingMode: Bool = false
    
    //MARK: - Status subscriptions
    public var isActive: Bool {
        get {
            if let expiryDate = UserDefaultsProperties.expiryDate {
                print("State subscription: \(expiryDate >= Date())")
                return expiryDate >= Date()
            } else {
                return self.isTestingMode
            }
        }
    }
    
    //MARK: - Configuration
    public func configuration() {
        
        self.getBundlesFromProductPlist()
        self.completionAllTransaction()
        self.verifySubscription()
    }
    
    //MARK: - Get bundles from plist
    fileprivate func getBundlesFromProductPlist() {
        
        if let products = GettingsKeysFromPlist.getAllKeys(from: .product) {
            products.forEach({ (key, value) in
                if let product = value as? String {
                    self.products.insert(product)
                } else {
                    print("Product: \(key), is not String value")
                }
            })
        }
    }
    
    //MARK: - Completion all transaction and start this method from AppDelegate
    fileprivate func completionAllTransaction() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    self.finishPurchaseRestoreTransaction(purchase: purchase)
                default: break
                }
            }
        }
    }
    
    //MARK: - Verify subscription
    fileprivate func verifySubscription(completion: ((_ result: Bool) -> ())? = nil) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
            switch result {
            case .success(receipt: let receipt):
                
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: self.products, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(expiryDate: let expiryDate, items: _):
                    
                    print("Product is valid until \(expiryDate)")
                    UserDefaultsProperties.expiryDate = expiryDate
                    completion?(true)
                case .expired(expiryDate: let expiryDate, items: _):
                    
                    print("Product is expired since \(expiryDate)")
                    completion?(false)
                case .notPurchased:
                    
                    print("The user has never purchased product")
                    completion?(false)
                }
                
            case .error(error: let error):
                
                print("Receipt verification failed: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    //MARK: - Purchase
    public func purchase(product: String, isTestingMode: Bool = false, completion: @escaping (_ result: PurchaseState) -> ()) {
        
        guard let product = GettingsKeysFromPlist.getKey(from: .product,
                                                         by: .init(rawValue: product)) as? String else {
            print("Product: \(product), is not valid")
            return
        }
        
        SwiftyStoreKit.purchaseProduct(product, simulatesAskToBuyInSandbox: false) { (result) in
            switch result {
            case .success(purchase: let purchase):
                
                self.isTestingMode = isTestingMode
                self.verifySubscription()
                self.finishPurchaseTransaction(purchase: purchase)
                
                UserAcquisitionManager.shared.logPurchase(of: purchase.product)
                AnalyticsManager.trackPurchase(eventName: .subscriptionDone,
                                               price: purchase.product.price.doubleValue,
                                               currency: purchase.product.priceLocale.currencyCode)
                
                completion(.successful)
            case .error(error: let error):
                
                switch error.code {
                case .paymentCancelled:
                    AnalyticsManager.trackWith(eventName: .subscriptionCancel)
                    completion(.cancelled)
                default:
                    AnalyticsManager.trackWith(eventName: .subscriptionCancel)
                    completion(.failed)
                }
            }
        }
    }
    
    //MARK: - Rectrive Info by products
    public func rectriveInfo(productBundle: String, completion: @escaping CompletionBlockSKProduct) {
        
        SwiftyStoreKit.retrieveProductsInfo(self.products) { (result) in
            if let product = result.retrievedProducts.first, product.productIdentifier == productBundle {
                print("ProductIdentifier: \(product.productIdentifier), price: \(product.localizedPrice!)")
                completion(product)
            } else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                completion(nil)
            } else {
                print("Error: \(result.error?.localizedDescription ?? "")")
                completion(nil)
            }
        }
    }
    
    //MARK: - Restore purchase
    public func restore(completion: @escaping (_ result: RestoreState) -> ()) {
        
        SwiftyStoreKit.restorePurchases(atomically: true) { (results) in
            
            if results.restoreFailedPurchases.count > 0 {
                
                AnalyticsManager.trackWith(eventName: .restoreFailed)
                completion(.failed)
            } else if results.restoredPurchases.count > 0 {
                
                results.restoredPurchases.forEach({ self.finishPurchaseRestoreTransaction(purchase: $0) })
                self.verifySubscription(completion: { (result) in
                    AnalyticsManager.trackWith(eventName: result ? .restoreDone : .restoreFailed)
                    completion(result ? .successful : .failed)
                })
            }
        }
    }
    
    //MARK: - Finish transaction
    fileprivate func finishPurchaseTransaction(purchase: PurchaseDetails) {
        
        if purchase.needsFinishTransaction { SwiftyStoreKit.finishTransaction(purchase.transaction) }
    }
    
    fileprivate func finishPurchaseRestoreTransaction(purchase: Purchase) {
        
        if purchase.needsFinishTransaction { SwiftyStoreKit.finishTransaction(purchase.transaction) }
    }
}
