// BootView.swift
// Cinematic boot screen with OS download integration.
import SwiftUI

struct BootView: View {
    @EnvironmentObject var systemState: SystemState
    @StateObject private var downloadService = OSDownloadService()

    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var rotation: Double = 0
    @State private var bootPhase: BootPhase = .logo

    enum BootPhase {
        case logo
        case downloading
        case ready
    }

    var body: some View {
        ZStack {
            // Background
            Color.wosBootGradient.ignoresSafeArea()

            // Animated background circles
            backgroundEffects

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Logo with glow
                logoSection

                Spacer().frame(height: 32)

                // Title
                titleSection

                Spacer().frame(height: 60)

                // Status section
                statusSection

                Spacer()

                // Version
                versionSection
            }
        }
        .onAppear {
            startBootAnimation()
            checkOS()
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(Color.wosAccent.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .rotationEffect(.degrees(rotation))

            // Middle glow
            Circle()
                .fill(Color.wosAccent.opacity(glowOpacity * 0.2))
                .frame(width: 100, height: 100)
                .blur(radius: 20)

            // Logo container
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.wosAccent, Color.wosAccentDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.wosAccent.opacity(0.5), radius: 30, x: 0, y: 10)

                Text("W")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("W OS")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .kerning(6)
                .opacity(textOpacity)

            Text("POWERING YOUR WORLD")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.wosTextMuted)
                .kerning(3)
                .opacity(textOpacity)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 16) {
            switch downloadService.state {
            case .idle, .ready:
                // Normal boot progress
                bootProgressBar

            case .checking:
                statusRow(icon: "magnifyingglass", text: "Kiểm tra hệ thống...", color: .wosAccent)

            case .downloading(let progress):
                VStack(spacing: 12) {
                    statusRow(icon: "arrow.down.circle.fill", text: "Đang tải hệ thống...", color: .wosAccent)

                    // Download progress
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.wosAccent, Color.wosAccentLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 6)
                                .animation(.linear, value: progress)
                        }
                    }
                    .frame(width: 200, height: 6)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.wosTextSecondary)
                }

            case .extracting:
                statusRow(icon: "archivebox.fill", text: "Đang giải nén...", color: .wosWarning)

            case .failed(let error):
                VStack(spacing: 12) {
                    statusRow(icon: "exclamationmark.triangle.fill", text: error, color: .wosDanger)

                    Button(action: { downloadService.downloadOS() }) {
                        Text("Thử lại")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.wosAccent)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    private var bootProgressBar: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.wosAccent, Color.wosAccentLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * (downloadService.isOSReady ? 1 : 0.3), height: 4)
                        .shadow(color: Color.wosAccent.opacity(0.5), radius: 8, x: 0, y: 0)
                }
            }
            .frame(width: 140, height: 4)

            Text(downloadService.isOSReady ? "Sẵn sàng" : "Đang khởi động...")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.wosTextMuted)
        }
    }

    private func statusRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.wosTextSecondary)
        }
    }

    // MARK: - Version

    private var versionSection: some View {
        VStack(spacing: 4) {
            if let version = downloadService.currentVersion {
                Text("v\(version.version) • Swift Native")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.wosTextDisabled)
            } else {
                Text("v2.2.0 • Swift Native")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.wosTextDisabled)
            }
        }
        .padding(.bottom, 40)
    }

    // MARK: - Background Effects

    private var backgroundEffects: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.wosAccent.opacity(0.05))
                    .frame(width: CGFloat(200 + i * 100), height: CGFloat(200 + i * 100))
                    .blur(radius: CGFloat(60 + i * 20))
                    .offset(
                        x: CGFloat(i % 2 == 0 ? -50 : 50),
                        y: CGFloat(i * 30)
                    )
            }
        }
    }

    // MARK: - Animations

    private func startBootAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoOpacity = 1
            logoScale = 1
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
            glowOpacity = 1
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
            ringOpacity = 1
            ringScale = 1
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.5)) {
            rotation = 360
        }
        withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
            textOpacity = 1
        }
    }

    private func checkOS() {
        // Check and download OS from GitHub
        downloadService.checkAndUpdateOS()

        // After OS is ready, proceed to next screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak systemState] in
            guard let systemState = systemState else { return }
            systemState.screen = systemState.hasSetup ? .lock : .setup
        }
    }
}

#Preview {
    BootView()
        .environmentObject(SystemState())
}
