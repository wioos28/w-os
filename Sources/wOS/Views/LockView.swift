// LockView.swift
// Modern iOS-style lock screen with haptic feedback, animated PIN dots, and gesture hints.
import SwiftUI

struct LockView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var now = Date()
    @State private var pin = ""
    @State private var error: String?
    @State private var shakeOffset: CGFloat = 0
    @State private var shakeRotation: Double = 0
    @State private var dotScales: [CGFloat] = Array(repeating: 1.0, count: 4)
    @State private var chevronOffset: CGFloat = 0
    @State private var ringRotation: Double = 0
    @State private var glowOpacity: Double = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ZStack {
            WallpaperBackground(wallpaperId: systemState.wallpaper)

            VStack(spacing: 26) {
                Spacer().frame(height: 50)

                // Clock
                VStack(spacing: 6) {
                    Text(timeString)
                        .font(.system(size: 56, weight: .thin))
                        .foregroundColor(.white)
                        .kerning(2)
                    Text(dateString)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "cccccc"))
                }

                // Avatar with rotating ring
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.wosAccent,
                                    Color.wosAccent.opacity(0.3),
                                    Color.wosAccent,
                                    Color.wosAccent.opacity(0.3),
                                    Color.wosAccent
                                ]),
                                center: .center
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(ringRotation))

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.wosAccent,
                                    Color.wosAccent.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            Text(avatarLetter)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.wosAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                }
                .onAppear {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                        ringRotation = 360
                    }
                }

                Text(systemState.userName.isEmpty ? "Người dùng" : systemState.userName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)

                // PIN dots with glow and shake
                VStack(spacing: 10) {
                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(pin.count > i ? Color.white : Color.white.opacity(0.25))
                                .frame(width: 13, height: 13)
                                .scaleEffect(dotScales[i])
                                .shadow(
                                    color: pin.count > i
                                        ? Color.wosAccent.opacity(glowOpacity)
                                        : Color.clear,
                                    radius: pin.count > i ? 8 : 0,
                                    x: 0, y: 0
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: pin.count > i)
                        }
                    }
                    .offset(x: shakeOffset)
                    .rotationEffect(.degrees(shakeRotation))

                    if let error {
                        Text(error)
                            .foregroundColor(.wosDanger)
                            .font(.system(size: 13))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowOpacity = 0.8
                    }
                }

                numpad

                Spacer()
            }
            .padding(.top, 20)

            // Swipe up gesture hint
            VStack {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Kéo lên để mở khóa")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .offset(y: chevronOffset)
                .padding(.bottom, 40)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                    ) {
                        chevronOffset = -8
                    }
                }
            }
        }
        .onReceive(timer) { now = $0 }
    }

    private var avatarLetter: String {
        let n = systemState.userName
        return n.isEmpty ? "?" : String(n.prefix(1)).uppercased()
    }

    private var timeString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm"
        return f.string(from: now)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: now)
    }

    private var numpad: some View {
        VStack(spacing: 14) {
            ForEach([["1","2","3"], ["4","5","6"], ["7","8","9"]], id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { digit in
                        numButton(digit) { addDigit(digit) }
                    }
                }
            }
            HStack(spacing: 20) {
                Color.clear.frame(width: 68, height: 68)
                numButton("0") { addDigit("0") }
                Button(action: removeDigit) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 68, height: 68)
                }
            }
        }
    }

    private func numButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                )
        }
    }

    private func addDigit(_ d: String) {
        guard pin.count < 4 else { return }

        haptic.impactOccurred()

        let currentIndex = pin.count

        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            dotScales[currentIndex] = 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                dotScales[currentIndex] = 1.0
            }
        }

        pin += d

        if pin.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { unlock() }
        }
    }

    private func removeDigit() {
        guard !pin.isEmpty else { return }
        haptic.impactOccurred(intensity: 0.5)
        pin.removeLast()
    }

    private func unlock() {
        if pin == systemState.password {
            error = nil
            pin = ""
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            systemState.screen = .desktop
        } else {
            error = "Sai mật khẩu"
            pin = ""
            dotScales = Array(repeating: 1.0, count: 4)

            let shakeCount = 6
            let shakeDuration = 0.04
            for i in 0..<shakeCount {
                let direction: CGFloat = i % 2 == 0 ? 12 : -12
                let rotDir: Double = i % 2 == 0 ? 2 : -2
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * shakeDuration) {
                    withAnimation(.easeInOut(duration: shakeDuration)) {
                        shakeOffset = direction
                        shakeRotation = rotDir
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(shakeCount) * shakeDuration) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    shakeOffset = 0
                    shakeRotation = 0
                }
            }
        }
    }
}
