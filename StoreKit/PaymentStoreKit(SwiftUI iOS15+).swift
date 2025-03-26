
import StoreKit

/*
 // ตั้งค่ารายชื่อสินค้า
 let productIds: Set<String> = ["com.app.topup.100coins", "com.app.topup.500coins"]

 // โหลดรายการสินค้า
 Task {
     await IAPManager.shared.loadProducts(productIds: productIds)
 }
 
 แสดงรายการสินค้า
 ForEach(IAPManager.shared.products, id: \.id) { product in
     Button("ซื้อ \(product.displayName) ราคา \(product.price.formatted(.currency(code: product.priceFormatStyle.currencyCode ?? "USD")))") {
         Task {
             let success = await IAPManager.shared.purchaseProduct(product)
             if success {
                 print("✅ ซื้อสำเร็จ: \(product.id)")
             }
         }
     }
 }

 กู้คืนการซื้อ
 Task {
     await IAPManager.shared.restorePurchases()
 }

 */

class PaymentStoreKitManager: ObservableObject {
    
    static let shared = PaymentStoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    /// โหลดรายการสินค้าจาก App Store
    func loadProducts(productIds: Set<String>) async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts
        } catch {
            print("❌ Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
    /// ทำการซื้อสินค้า
    func purchaseProduct(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                self.purchasedProductIDs.insert(transaction.productID)
                print("✅ Purchased: \(transaction.productID)")
                return true
            case .pending:
                print("🕐 Transaction pending")
                return false
            case .userCancelled:
                print("❌ User cancelled the purchase")
                return false
            @unknown default:
                print("❌ Unknown error during purchase")
                return false
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// กู้คืนการซื้อ (Restore Purchases)
    func restorePurchases() async {
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }
            DispatchQueue.main.async {
                self.purchasedProductIDs.insert(transaction.productID)
            }
            await transaction.finish()
        }
        print("✅ Restored Purchases: \(purchasedProductIDs)")
    }
}
