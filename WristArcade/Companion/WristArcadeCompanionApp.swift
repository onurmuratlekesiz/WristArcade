import SwiftUI

@main
struct WristArcadeCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            CompanionContentView()
        }
    }
}

struct CompanionContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "applewatch.radiowaves.left.and.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("WristArcade")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("60 OYUN")
                            .font(.system(size: 11, weight: .heavy))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.yellow)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Text("Apple Watch Koleksiyonu")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Installation Banner
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("Apple Watch'a Yükleme")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("1. iPhone'unuzdaki yerel Watch (Saatim) uygulamasını açın.\n2. Ekranın en altına kaydırın.\n3. 'Yüklenebilir Uygulamalar' listesinde WristArcade yanındaki 'Yükle' butonuna basın.\n4. Uygulama Apple Watch'unuza yüklenecektir!")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Categories Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎮 Dahil Edilen Oyun Kategorileri (60 Adet)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            
                            categoryRow(icon: "suit.spade.fill", color: .purple, title: "Kart & Casino", count: "10 Oyun", desc: "Blackjack, Video Poker, Solitaire, Baccarat...")
                            categoryRow(icon: "bolt.fill", color: .cyan, title: "Aksiyon & Arcade", count: "10 Oyun", desc: "Paddle, Snake, Crown Runner, Space Evade...")
                            categoryRow(icon: "brain.head.profile", color: .pink, title: "Refleks & Zeka", count: "10 Oyun", desc: "Reflex Tap, Color Memory, Math Blitz, Wing Flap...")
                            categoryRow(icon: "puzzlepiece.fill", color: .orange, title: "Bulmaca & Strateji", count: "10 Oyun", desc: "2048, Mines, Tic-Tac-Toe, Laser Mirror...")
                            categoryRow(icon: "crown.fill", color: .yellow, title: "Masa Oyunları", count: "10 Oyun", desc: "Satranç, Dama, Air Hockey, 9 Taş...")
                            categoryRow(icon: "gamecontroller.fill", color: .green, title: "Klasik & Mini", count: "10 Oyun", desc: "Hangman, Mini Sudoku, Lunar Lander, Darts...")
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        
                        // Sideloadly tips
                        VStack(alignment: .leading, spacing: 6) {
                            Text("İpucu: Geliştirici Modu")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("Apple Watch'unuzda uygulamayı ilk kez açarken 'Geliştirici Modu Gerekli' uyarısı alırsanız; Apple Watch Ayarlar -> Gizlilik ve Güvenlik -> Geliştirici Modu seçeneğini Açık yapın ve saatinizi yeniden başlatın.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                        .padding(14)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private func categoryRow(icon: String, color: Color, title: String, count: String, desc: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(count)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}
