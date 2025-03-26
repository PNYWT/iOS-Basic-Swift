
import StoreKit

/*
 // ตั้งค่า productIds
 let productIds: Set<String> = ["com.app.topup.100coins", "com.app.topup.500coins"]
 */

/*
 // โหลดรายการสินค้า
 class StoreViewController: UIViewController, IAPManagerDelegate {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 IAPManager.shared.delegate = self
 Task {
 await IAPManager.shared.loadProducts(productIds: productIds)
 }
 }
 
 func didUpdateProducts(_ products: [Product]) {
 print("✅ ได้รับรายการสินค้า: \(products)")
 // อัปเดต UI ตามสินค้าที่โหลดได้
 showPurchaseOptions(products)
 }
 
 func didCompletePurchase(productId: String) {
 print("✅ ซื้อสำเร็จ: \(productId)")
 // อัปเดต UI หรือแสดง Alert แจ้งเตือน
 }
 
 func didFailPurchase(error: Error?) {
 print("❌ การซื้อผิดพลาด: \(error?.localizedDescription ?? "Unknown Error")")
 // แสดง Alert แจ้งเตือน
 }
 
 func didRestorePurchases(productIds: [String]) {
 print("✅ กู้คืนสินค้าสำเร็จ: \(productIds)")
 // อัปเดต UI ว่าผู้ใช้กู้คืนสินค้าแล้ว
 }
 
 // สมมติว่า products ถูกโหลดแล้ว
 func showPurchaseOptions(products: [Product]) {
 for product in products {
 let button = UIButton(type: .system)
 button.setTitle("ซื้อ \(product.displayName) - \(product.price.formatted(.currency(code: "THB")))", for: .normal)
 button.addAction(UIAction { _ in
 Task {
 await IAPManager.shared.purchaseProduct(product)
 }
 }, for: .touchUpInside)
 
 view.addSubview(button)
 // กำหนดตำแหน่งของปุ่ม...
 }
 }
 }
 
 //  กู้คืนการซื้อ (Restore Purchases)
 @objc func restorePurchasesTapped() {
 Task {
 await IAPManager.shared.restorePurchases()
 }
 }
 */

protocol PaymentStoreKitManagerDelegate: AnyObject {
    func didUpdateProducts(_ products: [Product])
    func didCompletePurchase(productId: String)
    func didFailPurchase(error: Error?)
    func didRestorePurchases(productIds: [String])
}

@available(iOS 15.0, *)
class PaymentStoreKitManager {
    
    static let shared = PaymentStoreKitManager()
    weak var delegate: PaymentStoreKitManagerDelegate?
    
    private var products: [Product] = []
    private var purchasedProductIDs: Set<String> = []
    
    /// โหลดรายการสินค้าจาก App Store
    func loadProducts(productIds: Set<String>) async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts
            self.delegate?.didUpdateProducts(storeProducts)
        } catch {
            print("❌ Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
    /// ทำการซื้อสินค้า
    func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                purchasedProductIDs.insert(transaction.productID)
                self.delegate?.didCompletePurchase(productId: transaction.productID)
                print("✅ Purchased: \(transaction.productID)")
            case .pending:
                print("🕐 Transaction pending")
            case .userCancelled:
                print("❌ User cancelled the purchase")
            @unknown default:
                print("❌ Unknown error during purchase")
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            self.delegate?.didFailPurchase(error: error)
        }
    }
    
    /// กู้คืนการซื้อ (Restore Purchases)
    func restorePurchases() async {
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }
            purchasedProductIDs.insert(transaction.productID)
            self.delegate?.didRestorePurchases(productIds: [transaction.productID])
            await transaction.finish()
        }
        print("✅ Restored Purchases: \(purchasedProductIDs)")
    }
}
