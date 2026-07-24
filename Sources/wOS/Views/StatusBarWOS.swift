// StatusBarWOS.swift
// Modern glassmorphism status bar with animated elements.
import SwiftUI

struct StatusBarWOS: View {
    var onControlCenter: () -> Void
    var onNotifications: () -> Void
    var onSearch: () -> Void
    var onMultitask: () -> Void

    @State private var now = Date()
    @State private var batteryLevel: Double = 85
    @State private var isCharging = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var timeString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm"
        return f.string(from: now)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat: "EEE"
        return f.string(from: now)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Left section - Notifications
                Button(action: onNotifications) {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text(dateString)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
                .frame(width: 70, alignment: .leading)

                // Center section - Time
                Button(action: onSearch) {
                    HStack(spacing: 2) {
                        Text(timeString)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.4)
                        .onEnded { _ in onMultitask() }
                )
                .frame(maxWidth: .infinity)

                // Right section - Status icons
                Button(action: onControlCenter) {
                    HStack(spacing: 6) {
                        // WiFi icon
                        Image(systemName: "wifi")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)

                        // Signal bars
                        HStack(spacing: 1.5) {
                            ForEach(0..<4) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white)
                                    .frame(width: 2.5, height: CGFloat(4 + i * 2))
                            }
                        }

                        // Battery
                        HStack(spacing: 2) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    .frame(width: 20, height: 9)

                                RoundedRectangle(cornerRadius: 1)
                                    .fill(batteryColor)
                                    .frame(width: 16 * (batteryLevel / 100), height: 6)
                                    .padding(.leading, 1.5)
                            }

                            // Battery cap
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 1.5, height: 4)

                            Text("\(Int(batteryLevel))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )

            Spacer()
        }
        .onReceive(timer) { now = $0 }
        .zIndex(9999)
    }

    private var batteryColor: Color {
        if batteryLevel > 50 { return .wosSuccess }
        if batteryLevel > 20 { return .wosWarning }
        return .wosDanger
    }
}

#Preview {
    StatusBarWOS(
        onControlCenter: {},
        onNotifications: {},
        onSearch: {},
        onMultitask: {}
    )
}
