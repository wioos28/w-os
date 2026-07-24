// NotificationCenterView.swift
// Modern notification center with glassmorphism and animated cards.
import SwiftUI
import WOSCore

private struct NotifItem: Identifiable {
    let id: Int
    let app: String
    let symbol: String
    let color: Color
    let title: String
    let body: String
    let time: String
    let isNew: Bool
}

struct NotificationCenterView: View {
    var onClose: () -> Void
    @State private var appears = false

    private let notifications: [NotifItem] = [
        NotifItem(id: 1, app: "W OS", symbol: "bell.fill", color: .wosAccent,
                  title: "Chào mừng", body: "Cảm ơn bạn đã sử dụng W OS v2.1 (Swift Native)",
                  time: "Bây giờ", isNew: true),
        NotifItem(id: 2, app: "Cập nhật", symbol: "arrow.triangle.2.circlepath", color: .wosSuccess,
                  title: "Hệ thống", body: "W OS đang chạy phiên bản mới nhất",
                  time: "5 phút trước", isNew: true),
        NotifItem(id: 3, app: "Bảo mật", symbol: "lock.fill", color: .wosWarning,
                  title: "Màn hình khóa", body: "Mã PIN của bạn đã được lưu an toàn",
                  time: "10 phút trước", isNew: false),
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    // Handle
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 4)

                    // Header
                    HStack {
                        Text("Thông báo")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {}) {
                            Text("Xóa tất cả")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.wosAccent)
                        }
                    }

                    // Notifications list
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(notifications.enumerated()), id: \.element.id) { index, n in
                                notificationCard(n, index: index)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 50)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                )
                .frame(maxHeight: geo.size.height * 0.65)
                .offset(y: appears ? 0 : -20)
                .opacity(appears ? 1 : 0)

                Spacer()
            }
        }
        .background(Color.black.opacity(0.4).onTapGesture(perform: onClose))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appears = true
            }
        }
    }

    // MARK: - Notification Card

    private func notificationCard(_ n: NotifItem, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack(spacing: 10) {
                // App icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [n.color, n.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: n.symbol)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(n.app)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text(n.time)
                        .font(.system(size: 11))
                        .foregroundColor(Color.wosTextDisabled)
                }

                Spacer()

                // New indicator
                if n.isNew {
                    Circle()
                        .fill(Color.wosAccent)
                        .frame(width: 8, height: 8)
                }

                // Close button
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.wosTextDisabled)
                        .frame(width: 20, height: 20)
                        .background(Color.wosPanelAlt)
                        .clipShape(Circle())
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(n.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(n.body)
                    .font(.system(size: 13))
                    .foregroundColor(Color.wosTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color.wosPanel)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(n.isNew ? Color.wosAccent.opacity(0.3) : Color.wosBorder, lineWidth: n.isNew ? 1 : 0.5)
        )
        .shadow(color: n.isNew ? Color.wosAccent.opacity(0.1) : .clear, radius: 10, x: 0, y: 4)
        .offset(y: appears ? 0 : 20)
        .opacity(appears ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + Double(index) * 0.08), value: appears)
    }
}

#Preview {
    NotificationCenterView(onClose: {})
}
