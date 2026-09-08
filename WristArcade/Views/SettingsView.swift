import SwiftUI

public struct SettingsView: View {
    @AppStorage("haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = true
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var showingResetAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Section: Language / Dil
                VStack(alignment: .leading, spacing: 5) {
                    Text(i18n.t("preferences"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .foregroundColor(.cyan)
                                .font(.system(size: 11))
                            Text(i18n.t("language_label"))
                                .font(.system(size: 11))
                            Spacer()
                        }
                        
                        Picker(i18n.t("language_label"), selection: $i18n.selectedLanguage) {
                            Text(i18n.t("lang_auto")).tag("auto")
                            Text("English").tag("en")
                            Text("Türkçe").tag("tr")
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 48)
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                    
                    Toggle(isOn: $hapticsEnabled) {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.cyan)
                            Text(i18n.t("haptic_feedback"))
                                .font(.system(size: 11))
                        }
                    }
                    .toggleStyle(.switch)
                    
                    Toggle(isOn: $soundEnabled) {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.green)
                            Text(i18n.t("sound_effects"))
                                .font(.system(size: 11))
                        }
                    }
                    .toggleStyle(.switch)
                    
                    // Display Theme Selector
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 11))
                            Text(i18n.t("theme_label"))
                                .font(.system(size: 11))
                            Spacer()
                        }
                        
                        Picker(i18n.t("theme_label"), selection: Binding(
                            get: { ThemeManager.shared.currentTheme },
                            set: { ThemeManager.shared.currentTheme = $0 }
                        )) {
                            ForEach(ArcadeTheme.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 48)
                    }
                    
                    // Wrist Tilt Motion Sensitivity
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Image(systemName: "gyroscope")
                                .foregroundColor(.green)
                                .font(.system(size: 11))
                            Text(i18n.t("motion_sensitivity"))
                                .font(.system(size: 11))
                            Spacer()
                        }
                        
                        HStack(spacing: 4) {
                            Button(action: { MotionManager.shared.setSensitivity(0.5) }) {
                                Text("0.5x")
                                    .font(.system(size: 9, weight: MotionManager.shared.sensitivity == 0.5 ? .bold : .regular))
                                    .foregroundColor(MotionManager.shared.sensitivity == 0.5 ? .black : .white)
                                    .padding(.vertical, 3)
                                    .frame(maxWidth: .infinity)
                                    .background(MotionManager.shared.sensitivity == 0.5 ? Color.green : Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { MotionManager.shared.setSensitivity(1.0) }) {
                                Text("1.0x")
                                    .font(.system(size: 9, weight: MotionManager.shared.sensitivity == 1.0 ? .bold : .regular))
                                    .foregroundColor(MotionManager.shared.sensitivity == 1.0 ? .black : .white)
                                    .padding(.vertical, 3)
                                    .frame(maxWidth: .infinity)
                                    .background(MotionManager.shared.sensitivity == 1.0 ? Color.green : Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { MotionManager.shared.setSensitivity(1.5) }) {
                                Text("1.5x")
                                    .font(.system(size: 9, weight: MotionManager.shared.sensitivity == 1.5 ? .bold : .regular))
                                    .foregroundColor(MotionManager.shared.sensitivity == 1.5 ? .black : .white)
                                    .padding(.vertical, 3)
                                    .frame(maxWidth: .infinity)
                                    .background(MotionManager.shared.sensitivity == 1.5 ? Color.green : Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Section: Fitness & Health Quest
                VStack(alignment: .leading, spacing: 6) {
                    Text(i18n.t("fitness_title"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text(i18n.t("fitness_steps"))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(FitnessManager.shared.currentSteps) / \(FitnessManager.shared.dailyStepsGoal)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        if FitnessManager.shared.claimDailyBonus(scoreManager: scoreManager) {
                            HapticManager.shared.play(.victory)
                        }
                    }) {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text(FitnessManager.shared.hasClaimedTodayBonus ? "Claimed Today" : i18n.t("claim_xp"))
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                        .background(FitnessManager.shared.hasClaimedTodayBonus ? Color.gray : Color.green)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(FitnessManager.shared.hasClaimedTodayBonus)
                }
                .padding(.horizontal, 6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Section: Stats & Scores
                VStack(alignment: .leading, spacing: 6) {
                    Text(i18n.t("data_stats"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(i18n.t("total_sessions"))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(scoreManager.totalGamesPlayed)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Text(i18n.t("reset_scores"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(Color.red.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 6)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Section: Legal & Pro Status
                VStack(spacing: 4) {
                    if storeKit.isProUser {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.yellow)
                            Text(i18n.t("pro_activated"))
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.yellow)
                        }
                    } else {
                        Button(action: {
                            Task { await storeKit.restorePurchases() }
                        }) {
                            Text(i18n.t("restore_purchases"))
                                .font(.system(size: 10))
                                .foregroundColor(.cyan)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text(i18n.t("version_info"))
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .padding(.bottom, 10)
        }
        .navigationTitle(i18n.t("settings_title"))
        .alert(i18n.t("reset_confirm_title"), isPresented: $showingResetAlert) {
            Button(i18n.t("reset_btn"), role: .destructive) {
                scoreManager.resetScores()
                HapticManager.shared.play(.victory)
            }
            Button(i18n.t("cancel"), role: .cancel) {}
        } message: {
            Text(i18n.t("reset_confirm_msg"))
        }
    }
}
