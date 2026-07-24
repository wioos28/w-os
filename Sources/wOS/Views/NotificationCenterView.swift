// NotificationCenterView.swift
// Ported 1:1 from src/screens/NotificationCenter.js
import SwiftUI

private struct NotifItem: Identifiable {
    let id: Int
    let app: String
    let symbol: String
    let color: Color
    let title: String
    let body: String
    let time: String
}

struct NotificationCenterView: View {
    var onClose: () -> Void

    private let notifications: [NotifItem] = [
        NotifItem(id: 1, app: "W OS", symbol: "bell.fill", color: .wosAccent, title: "Chào mừng", body: "Cảm ơn bạn đã sử dụng W OS v2.1 (Swift)", time: "Bây giờ"),
        NotifItem(id: 2, app: "Cập nhật", symbol: "arrow.triangle.2.circlepath", color: .wosSuccess, title: "Hệ thống", body: "W OS đang chạy phiên bản Swift mới nhất", time: "5 phút trước"),
        NotifItem(id: 3, app: "Bảo mật", symbol: "lock.fill", color: .wosWarning, title: "Màn hình khóa", body: "Mật khẩu của bạn đã được lưu an toàn", time: "10 phút trước"),
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Capsule().fill(Color(hex: "444444")).frame(width: 36, height: 4)
                    Text("Thông báo").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(notifications) { n in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 6).fill(n.color).frame(width: 20, height: 20)
                                            .overlay(Image(systemName: n.symbol).font(.system(size: 11)).foregroundColor(.white))
                                        Text(n.app).font(.system(size: 12)).foregroundColor(Color(hex: "888888"))
                                        Spacer()
                                        Text(n.time).font(.system(size: 11)).foregroundColor(Color(hex: "555555"))
                                    }
                                    Text(n.title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                    Text(n.body).font(.system(size: 13)).foregroundColor(Color(hex: "aaaaaa"))
                                }
                                .padding(14)
                                .background(Color(hex: "1a1a1a"))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 40)
                .background(.ultraThinMaterial)
                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                .frame(maxHeight: geo.size.height * 0.6)
                Spacer()
            }
        }
        .background(Color.black.opacity(0.001).onTapGesture(perform: onClose))
    }
}
