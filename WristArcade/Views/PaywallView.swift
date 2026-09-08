import SwiftUI

public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                // Header Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                .padding(.top, 4)
                
                Text(i18n.t("paywall_title"))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text(i18n.t("paywall_subtitle"))
                    .font(.system(size: 9))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                
                // Feature Bullets
                VStack(alignment: .leading, spacing: 3) {
                    featureRow(icon: "gamecontroller.fill", text: i18n.t("paywall_feature_1"))
                    featureRow(icon: "suit.spade.fill", text: i18n.t("paywall_feature_2"))
                    featureRow(icon: "crown.fill", text: i18n.t("paywall_feature_3"))
                    featureRow(icon: "icloud.slash.fill", text: i18n.t("paywall_feature_4"))
                }
                .padding(.vertical, 3)
                
                // Purchase Button
                Button(action: {
                    Task {
                        let success = await storeKit.purchasePro()
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if storeKit.purchaseState == .purchasing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("\(i18n.t("paywall_buy_button")) \(storeKit.proProduct?.displayPrice ?? "$2.99")")
                                .font(.system(size: 10, weight: .heavy))
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(storeKit.purchaseState == .purchasing)
                .padding(.horizontal, 8)
                
                // Restore Purchases
                Button(action: {
                    Task {
                        await storeKit.restorePurchases()
                        if storeKit.isProUser {
                            dismiss()
                        }
                    }
                }) {
                    Text(i18n.t("restore_purchases"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .padding(.top, 1)
            }
            .padding(.bottom, 10)
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.yellow)
            Text(text)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}
