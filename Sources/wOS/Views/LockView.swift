// LockView.swift
// Ported 1:1 from src/screens/LockScreen.js (clock, avatar, PIN dots, numpad, shake-on-error).
import SwiftUI

struct LockView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var now = Date()
    @State private var pin = ""
    @State private var error: String?
    @State private var shakeOffset: CGFloat = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            WallpaperBackground(wallpaperId: systemState.wallpaper)

            VStack(spacing: 26) {
                Spacer().frame(height: 50)
                VStack(spacing: 6) {
                    Text(timeString).font(.system(size: 56, weight: .thin)).foregroundColor(.white).kerning(2)
                    Text(dateString).font(.system(size: 16)).foregroundColor(Color(hex: "cccccc"))
                }

                VStack(spacing: 10) {
                    Circle()
                        .fill(Color.wosAccent)
                        .frame(width: 70, height: 70)
                        .overlay(Text(avatarLetter).font(.system(size: 28, weight: .bold)).foregroundColor(.white))
                    Text(systemState.userName.isEmpty ? "Người dùng" : systemState.userName)
                        .font(.system(size: 18, weight: .medium)).foregroundColor(.white)
                }

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(pin.count > i ? Color.white : Color.clear)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .offset(x: shakeOffset)
                    if let error {
                        Text(error).foregroundColor(.wosDanger).font(.system(size: 13))
                    }
                }

                numpad
            }
            .padding(.top, 20)
        }
        .onReceive(timer) { now = $0 }
    }

    private var avatarLetter: String {
        let n = systemState.userName
        return n.isEmpty ? "?" : String(n.prefix(1)).uppercased()
    }

    private var timeString: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "HH:mm"
        return f.string(from: now)
    }
    private var dateString: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "EEEE, d MMMM"
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
                    Image(systemName: "delete.left").font(.system(size: 22)).foregroundColor(.white)
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
                .background(Circle().fill(Color.white.opacity(0.12)))
        }
    }

    private func addDigit(_ d: String) {
        guard pin.count < 4 else { return }
        pin += d
        if pin.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { unlock() }
        }
    }

    private func removeDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }

    private func unlock() {
        if pin == systemState.password {
            error = nil
            pin = ""
            systemState.screen = .desktop
        } else {
            error = "Sai mật khẩu"
            pin = ""
            withAnimation(.linear(duration: 0.05)) { shakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { withAnimation(.linear(duration: 0.05)) { shakeOffset = -10 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { withAnimation(.linear(duration: 0.05)) { shakeOffset = 10 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { withAnimation(.linear(duration: 0.05)) { shakeOffset = 0 } }
        }
    }
}
