import SwiftyStoreKit

final class StoreManager: NSObject {
    
    //MARK: - Enums
    public enum ProductsIds {
        case year1, year2, year3,
             month1, month2, month3,
             week1, week2, week3
        
        static let identifiers: Set<String> = [year1.identifier, year2.identifier, year3.identifier,
                                               month1.identifier, month2.identifier, month3.identifier,
                                               week1.identifier, week2.identifier, week3.identifier]
        
        var identifier: String {
            switch self {
            case .year1:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "year1")) as? String ?? ""
            case .year2:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "year2")) as? String ?? ""
            case .year3:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "year3")) as? String ?? ""
            case .month1:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "month1")) as? String ?? ""
            case .month2:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "month2")) as? String ?? ""
            case .month3:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "month3")) as? String ?? ""
            case .week1:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "week1")) as? String ?? ""
            case .week2:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "week2")) as? String ?? ""
            case .week3:
                return GettingsKeysFromPlist.getKey(by: .init(rawValue: "week3")) as? String ?? ""
            }
        }
    }
    
    public enum PurchaseState {
        case successful, failed, cancelled
    }
    
    public enum RestoreState {
        case successful, failed
    }
    
    //MARK: - Singleton
    public static let shared = StoreManager()
    
    //MARK: - Properties
    fileprivate let sharedKey = GettingsKeysFromPlist.getKey(by: .sharedKey) as! String
    
    //MARK: - Status subscriptions
    public var isActive: Bool {
        get {
            if let expiryDate = UserDefaultsProperties.expiryDate {
                print("State subscription: \(expiryDate <= Date())")
                return expiryDate <= Date()
            } else {
                return false
            }
        }
    }
    
    //MARK: - Configuration
    public func configuration() {
        
        self.completionAllTransaction()
        self.verifySubscription()
    }
    
    //MARK: - Completion all transaction and start this method from AppDelegate
    fileprivate func completionAllTransaction() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
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
                
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: ProductsIds.identifiers, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(expiryDate: let expiryDate, items: _):
                    
                    print("\(ProductsIds.identifiers) is valid until \(expiryDate)")
                    UserDefaultsProperties.expiryDate = expiryDate
                    completion?(true)
                case .expired(expiryDate: let expiryDate, items: _):
                    
                    print("\(ProductsIds.identifiers) is expired since \(expiryDate)")
                    completion?(false)
                case .notPurchased:
                    
                    print("The user has never purchased \(ProductsIds.identifiers)")
                    completion?(false)
                }
                
            case .error(error: let error):
                
                print("Receipt verification failed: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    //MARK: - Purchase
    public func purchase(product: ProductsIds, completion: @escaping (_ result: PurchaseState) -> ()) {
        
        SwiftyStoreKit.purchaseProduct(product.identifier, simulatesAskToBuyInSandbox: false) { (result) in
            switch result {
            case .success(purchase: let purchase):
                
                self.verifySubscription()
                self.finishPurchaseTransaction(purchase: purchase)
                
                UserAcquisition.shared.logPurchase(of: purchase.product)
                AnalyticsManager.trackPurchase(eventName: .init(rawValue: "Subscription_Done"),
                                               price: purchase.product.price.doubleValue,
                                               currency: purchase.product.priceLocale.currencyCode)
                
                completion(.successful)
            case .error(error: let error):
                
                switch error.code {
                case .paymentCancelled:
                    AnalyticsManager.trackWith(eventName: .init(rawValue: "Subscription_Cancel"))
                    completion(.cancelled)
                default:
                    AnalyticsManager.trackWith(eventName: .init(rawValue: "Subscription_Failed"))
                    completion(.failed)
                }
            }
        }
    }
    
    //MARK: - Rectrive Info by products
    public func rectriveInfo() {
        
        SwiftyStoreKit.retrieveProductsInfo(ProductsIds.identifiers) { (result) in
            if let product = result.retrievedProducts.first {
                
                print("ProductIdentifier: \(product.productIdentifier), price: \(product.localizedPrice!)")
            } else if let invalidProductId = result.invalidProductIDs.first {
                
                print("Invalid product identifier: \(invalidProductId)")
            } else {
                
                print("Error: \(result.error?.localizedDescription ?? "")")
            }
        }
    }
    
    //MARK: - Restore purchase
    public func restore(completion: @escaping (_ result: RestoreState) -> ()) {
        
        SwiftyStoreKit.restorePurchases(atomically: true) { (results) in
            
            if results.restoreFailedPurchases.count > 0 {
                
                AnalyticsManager.trackWith(eventName: .init(rawValue: "Restore_Failed"))
                completion(.failed)
            } else if results.restoredPurchases.count > 0 {
                
                results.restoredPurchases.forEach({ self.finishPurchaseRestoreTransaction(purchase: $0) })
                self.verifySubscription(completion: { (result) in
                    AnalyticsManager.trackWith(eventName: result ? .init(rawValue: "Restore_Done") : .init(rawValue: "Restore_Failed"))
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
