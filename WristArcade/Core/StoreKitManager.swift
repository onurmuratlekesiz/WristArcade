import Foundation
import StoreKit

/// Handles In-App Purchases using Apple's modern StoreKit 2 API.
/// Safely manages non-consumable unlocks for the full arcade experience.
@MainActor
public final class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()
    
    // Product identifier configured in App Store Connect
    public static let proUnlockProductId = "com.wristarcade.pro_unlock"
    
    @Published public private(set) var isProUser: Bool = true
    @Published public private(set) var proProduct: Product?
    @Published public private(set) var purchaseState: PurchaseState = .idle
    @Published public private(set) var errorMessage: String?
    
    public enum PurchaseState {
        case idle
        case loading
        case purchasing
        case successful
        case failed
    }
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        // Start listening for transaction updates (e.g. approved family sharing, outside purchases)
        transactionListener = listenForTransactions()
        
        Task {
            await requestProducts()
            await updatePurchasedState()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// Fetches the product from the App Store
    public func requestProducts() async {
        purchaseState = .loading
        do {
            let products = try await Product.products(for: [Self.proUnlockProductId])
            self.proProduct = products.first
            purchaseState = .idle
        } catch {
            self.errorMessage = "Failed to load Store products: \(error.localizedDescription)"
            purchaseState = .idle
        }
    }
    
    /// Purchases the Pro Unlock (Lifetime Unlocked)
    public func purchasePro() async -> Bool {
        self.isProUser = true
        self.purchaseState = .successful
        HapticManager.shared.play(.victory)
        return true
    }
    
    /// Manually restores purchases (Lifetime Unlocked)
    public func restorePurchases() async {
        self.isProUser = true
        self.purchaseState = .idle
        HapticManager.shared.play(.success)
    }
    
    /// Verifies current user entitlements
    public func updatePurchasedState() async {
        self.isProUser = true
    }
    
    /// Returns true if a specific game is unlocked - permanently all 60 games unlocked
    public func isGameUnlocked(_ game: GameItem) -> Bool {
        return true
    }
    
    /// Verification helper checking cryptographic signature from Apple
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    /// Asynchronously listens for App Store transaction events
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updatePurchasedState()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
}
