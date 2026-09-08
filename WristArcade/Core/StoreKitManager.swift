import Foundation
import StoreKit

/// Handles In-App Purchases using Apple's modern StoreKit 2 API.
/// Safely manages non-consumable unlocks for the full arcade experience.
@MainActor
public final class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()
    
    // Product identifier configured in App Store Connect
    public static let proUnlockProductId = "com.wristarcade.pro_unlock"
    
    @Published public private(set) var isProUser: Bool = false
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
            purchaseState = .failed
        }
    }
    
    /// Purchases the Pro Unlock
    public func purchasePro() async -> Bool {
        guard let product = proProduct else {
            errorMessage = "Product not loaded yet."
            return false
        }
        
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedState()
                purchaseState = .successful
                HapticManager.shared.play(.victory)
                return true
            case .userCancelled:
                purchaseState = .idle
                return false
            case .pending:
                purchaseState = .idle
                return false
            @unknown default:
                purchaseState = .idle
                return false
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.purchaseState = .failed
            HapticManager.shared.play(.error)
            return false
        }
    }
    
    /// Manually restores purchases
    public func restorePurchases() async {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await updatePurchasedState()
            purchaseState = .idle
            HapticManager.shared.play(.success)
        } catch {
            self.errorMessage = "Could not sync purchases: \(error.localizedDescription)"
            purchaseState = .failed
            HapticManager.shared.play(.error)
        }
    }
    
    /// Verifies current user entitlements
    public func updatePurchasedState() async {
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.proUnlockProductId && transaction.revocationDate == nil {
                    hasPro = true
                    break
                }
            }
        }
        self.isProUser = hasPro
    }
    
    /// Returns true if a specific game is unlocked (free game, pro user, or today's Daily Free Pro pass)
    public func isGameUnlocked(_ game: GameItem) -> Bool {
        if !game.isPro { return true }
        if isProUser { return true }
        if game.id == ScoreManager.dailyFreeProGameId() { return true }
        return false
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
