// UpdateAppView.swift
// NEW app requested on top of the original screens: a dedicated system
// "Cập nhật" (Update) screen, reachable from the desktop grid and Settings.
import SwiftUI

struct UpdateAppView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var checking = false
    @State private var lastChecked: Date?
    @State private var upToDate = true

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 24).fill(Color.wosAccent).frame(width: 84, height: 84)
                .overlay(Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 34)).foregroundColor(.white))
                .padding(.top, 30)

            VStack(spacing: 4) {
                Text("W OS 2.1.0").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Text("Swift Native Build").font(.system(size: 13)).foregroundColor(Color(hex: "888888"))
            }

            VStack(alignment: .leading, spacing: 10) {
                infoRow("Kiến trúc", "SwiftUI / iOS Native")
                infoRow("Boot Drive", systemState.bootDriveMode.label)
                if let lastChecked {
                    infoRow("Kiểm tra lần cuối", formatted(lastChecked))
                }
            }
            .padding(14)
            .background(Color(hex: "111111"))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
            .padding(.horizontal, 20)

            if upToDate {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(.wosSuccess)
                    Text("Hệ thống đang chạy phiên bản mới nhất").foregroundColor(.wosSuccess).font(.system(size: 13))
                }
            }

            Button(action: checkForUpdate) {
                HStack(spacing: 8) {
                    if checking { ProgressView().tint(.white) } else { Image(systemName: "arrow.clockwise") }
                    Text(checking ? "Đang kiểm tra..." : "Kiểm tra cập nhật")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.wosAccent)
                .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .disabled(checking)

            Spacer()

            Text("Được build & phân phối qua Codemagic CI/CD.")
                .font(.system(size: 11)).foregroundColor(Color(hex: "555555"))
                .padding(.bottom, 20)
        }
        .background(Color.wosBackground)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(Color(hex: "888888"))
            Spacer()
            Text(value).font(.system(size: 13, weight: .medium)).foregroundColor(.white).lineLimit(1)
        }
    }

    private func checkForUpdate() {
        checking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            checking = false
            upToDate = true
            lastChecked = Date()
        }
    }

    private func formatted(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "HH:mm, d/M/yyyy"
        return f.string(from: d)
    }
}
