// StatusBarWOS.swift
// Adaptive status bar - horizontal (portrait) or vertical (landscape).
import SwiftUI
import WOSCore

struct StatusBarWOS: View {
    var onControlCenter: () -> Void
    var onNotifications: () -> Void
    var onSearch: () -> Void
    var onMultitask: () -> Void
    var isVertical: Bool = false

    @State private var now = Date()
    @State private var batteryLevel: Double = 85
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
        f.dateFormat = "EEE"
        return f.string(from: now)
    }

    var body: some View {
        if isVertical {
            verticalLayout
        } else {
            horizontalLayout
        }
    }

    // MARK: - Horizontal Layout (Portrait)

    private var horizontalLayout: some View {
        HStack(spacing: 0) {
            // Left - Notifications
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

            // Center - Time
            Button(action: onSearch) {
                Text(timeString)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in onMultitask() }
            )
            .frame(maxWidth: .infinity)

            // Right - Status
            Button(action: onControlCenter) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi")
                        .font(.system(size: 12, weight: .medium))
                    batteryView
                }
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.ultraThinMaterial.opacity(0.8))
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Vertical Layout (Landscape)

    private var verticalLayout: some View {
        VStack(spacing: 0) {
            // Time
            Button(action: onSearch) {
                VStack(spacing: 2) {
                    Text(timeString)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text(dateString)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.wosTextMuted)
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in onMultitask() }
            )

            Spacer()

            // Notifications
            Button(action: onNotifications) {
                VStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Noti")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white)
            }

            Spacer()

            // Control Center
            Button(action: onControlCenter) {
                VStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                    Text("CC")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white)
            }

            Spacer()

            // Battery
            VStack(spacing: 4) {
                batteryView
                Text("\(Int(batteryLevel))%")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 16)
        .frame(width: 44)
        .background(.ultraThinMaterial.opacity(0.8))
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Battery

    private var batteryView: some View {
        HStack(spacing: 2) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .frame(width: 18, height: 9)
                RoundedRectangle(cornerRadius: 1)
                    .fill(batteryColor)
                    .frame(width: 14 * (batteryLevel / 100), height: 6)
                    .padding(.leading, 1.5)
            }
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.4))
                .frame(width: 1.5, height: 4)
        }
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
        onMultitask: {},
        isVertical: true
    )
}
