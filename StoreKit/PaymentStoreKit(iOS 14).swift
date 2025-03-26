
import StoreKit

/*
 ตั้งค่ารายชื่อสินค้า (Product IDs)
 let productIds: Set<String> = ["com.app.topup.100coins", "com.app.topup.500coins"]
 
 โหลดรายการสินค้า
 IAPManager.shared.delegate = self
 IAPManager.shared.loadProducts(productIds: productIds)
 
 เริ่มทำการซื้อ
 IAPManager.shared.purchaseProduct(productId: "com.app.topup.100coins")

 กู้คืนการซื้อ
 IAPManager.shared.restorePurchases()
 */

protocol PaymentStoreKitManagerDelegate: AnyObject {
    func didUpdateProducts(_ products: [SKProduct])
    func didCompletePurchase(productId: String)
    func didFailPurchase(error: Error?)
    func didRestorePurchases(productIds: [String])
}

class PaymentStoreKitManager: NSObject {
    
    static let shared = PaymentStoreKitManager()
    
    weak var delegate: PaymentStoreKitManagerDelegate?
    
    private var products: [SKProduct] = []
    private var productRequest: SKProductsRequest?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    /// โหลดสินค้า In-App Purchase จาก App Store
    func loadProducts(productIds: Set<String>) {
        productRequest?.cancel()
        productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    /// เริ่มทำการซื้อสินค้า
    func purchaseProduct(productId: String) {
        guard let product = products.first(where: { $0.productIdentifier == productId }) else {
            delegate?.didFailPurchase(error: NSError(domain: "IAP", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    /// กู้คืนการซื้อ (Restore Purchases)
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension PaymentStoreKitManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugPrint("productsRequest")
        self.products = response.products
        delegate?.didUpdateProducts(response.products)
    }
}

// MARK: - SKPaymentTransactionObserver
extension PaymentStoreKitManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        debugPrint("paymentQueue")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                delegate?.didCompletePurchase(productId: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                delegate?.didFailPurchase(error: transaction.error)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                delegate?.didRestorePurchases(productIds: [transaction.payment.productIdentifier])
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
