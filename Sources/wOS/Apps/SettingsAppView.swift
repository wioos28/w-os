// SettingsAppView.swift
// Ported 1:1 from src/screens/SettingsScreen.js, extended with the new
// boot-drive section (self-build vs admin-built) the user asked for.
import SwiftUI

struct SettingsAppView: View {
    @EnvironmentObject var systemState: SystemState
    @StateObject private var bootDrive = BootDriveService()

    @State private var appSize = "medium"
    @State private var darkMode = true
    @State private var apiUrl = ""
    @State private var testing = false
    @State private var connStatus: Bool?
    @State private var repoUrl = ""
    @State private var showResetConfirm = false
    @State private var showUpdateAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Profile card
                HStack(spacing: 12) {
                    Circle().fill(Color.wosAccent).frame(width: 54, height: 54)
                        .overlay(Text(avatarLetter).font(.system(size: 22, weight: .bold)).foregroundColor(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(systemState.userName.isEmpty ? "Người dùng" : systemState.userName)
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Text("W OS Account").font(.system(size: 12)).foregroundColor(Color(hex: "888888"))
                    }
                }

                sectionTitle("Giao diện")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))], spacing: 10) {
                    ForEach(WallpaperCatalog.all) { wp in
                        VStack(spacing: 4) {
                            WallpaperBackground(wallpaperId: wp.id, dim: 0.1)
                                .frame(width: 50, height: 68)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(systemState.wallpaper == wp.id ? Color.wosAccent : .clear, lineWidth: 2))
                            Text(wp.label).font(.system(size: 11)).foregroundColor(Color(hex: "888888"))
                        }
                        .onTapGesture { systemState.setWallpaper(wp.id) }
                    }
                }

                sectionTitle("Hệ điều hành (Boot Drive)")
                bootDriveCard

                sectionTitle("Dữ liệu đám mây")
                cloudCard

                sectionTitle("Chung")
                settingRow(icon: "arrow.triangle.2.circlepath", title: "Cập nhật phần mềm") { showUpdateAlert = true }
                settingRow(icon: "arrow.up.left.and.arrow.down.right", title: "Kích thước ứng dụng", value: appSize) { appSize = appSize == "medium" ? "large" : "medium" }
                settingRow(icon: "moon.fill", title: "Chế độ tối", value: darkMode ? "Bật" : "Tắt") { darkMode.toggle() }
                settingRow(icon: "key.fill", title: "Đổi mật khẩu") {}
                settingRow(icon: "gearshape.fill", title: "Mở Cài đặt hệ thống thật") { LinkingService.openSystemSettings() }

                sectionTitle("Hệ thống")
                settingRow(icon: "info.circle.fill", title: "Giới thiệu W OS") {}
                settingRow(icon: "trash.fill", title: "Khôi phục cài đặt gốc", danger: true) { showResetConfirm = true }
                settingRow(icon: "lock.fill", title: "Đăng xuất", danger: true) { systemState.screen = .lock }
            }
            .padding(16)
        }
        .background(Color.wosBackground)
        .onAppear { apiUrl = CloudSyncService.shared.baseURL }
        .alert("Cập nhật hệ thống", isPresented: $showUpdateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("W OS đang chạy phiên bản mới nhất (2.1.0 — Swift Native).")
        }
        .alert("Khôi phục cài đặt gốc?", isPresented: $showResetConfirm) {
            Button("Hủy", role: .cancel) {}
            Button("Khôi phục", role: .destructive) { systemState.factoryReset() }
        } message: {
            Text("Toàn bộ dữ liệu cục bộ sẽ bị xóa.")
        }
    }

    private var avatarLetter: String {
        let n = systemState.userName
        return n.isEmpty ? "?" : String(n.prefix(1)).uppercased()
    }

    private var bootDriveCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hiện tại: \(systemState.bootDriveMode.label)")
                .font(.system(size: 12)).foregroundColor(Color(hex: "999999"))

            HStack(spacing: 8) {
                Button("Tự Build từ Repo") {
                    guard !repoUrl.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    bootDrive.buildFromRepo(repoUrl) { res in
                        if case .success(let src) = res { systemState.setBootDriveMode(.selfBuild(source: src)) }
                    }
                }
                .buttonStyle(WOSSmallButtonStyle())

                Button("Dùng Admin Build") {
                    bootDrive.useAdminDrive { res in
                        if case .success = res { systemState.setBootDriveMode(.adminBuilt) }
                    }
                }
                .buttonStyle(WOSSmallButtonStyle(ghost: true))
            }

            TextField("", text: $repoUrl, prompt: Text("URL repo mã nguồn...").foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .autocapitalization(.none)

            statusLine
        }
        .padding(14)
        .background(Color(hex: "111111"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    @ViewBuilder
    private var statusLine: some View {
        switch bootDrive.status {
        case .idle: EmptyView()
        case .cloning, .building:
            HStack(spacing: 6) { ProgressView().tint(.wosAccent); Text("Đang xử lý...").foregroundColor(Color(hex: "aaaaaa")).font(.system(size: 12)) }
        case .ready:
            HStack(spacing: 6) { Image(systemName: "checkmark.circle.fill").foregroundColor(.wosSuccess); Text("Đã cập nhật boot drive").foregroundColor(.wosSuccess).font(.system(size: 12)) }
        case .failed(let msg):
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosDanger); Text(msg).foregroundColor(.wosDanger).font(.system(size: 12)) }
        }
    }

    private var cloudCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Địa chỉ server (đồng bộ ghi chú & danh mục app)")
                .font(.system(size: 11)).foregroundColor(Color(hex: "777777"))
            TextField("", text: $apiUrl, prompt: Text("https://ten-server-cua-ban.example.com").foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .autocapitalization(.none)
            HStack(spacing: 8) {
                Button(action: saveApiUrl) {
                    HStack(spacing: 6) { Image(systemName: "square.and.arrow.down.fill"); Text("Lưu & kiểm tra") }
                }
                .buttonStyle(WOSSmallButtonStyle())
                Button(action: testConnection) {
                    HStack(spacing: 6) {
                        if testing { ProgressView().tint(.wosAccent) } else { Image(systemName: "arrow.triangle.2.circlepath") }
                        Text("Kiểm tra")
                    }
                }
                .buttonStyle(WOSSmallButtonStyle(ghost: true))
            }
            if let connStatus {
                HStack(spacing: 6) {
                    Image(systemName: connStatus ? "checkmark.icloud.fill" : "xmark.icloud.fill")
                        .foregroundColor(connStatus ? .wosSuccess : .wosDanger)
                    Text(connStatus ? "Đã kết nối" : "Chưa kết nối được")
                        .foregroundColor(connStatus ? .wosSuccess : .wosDanger).font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .padding(14)
        .background(Color(hex: "111111"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    private func saveApiUrl() {
        CloudSyncService.shared.baseURL = apiUrl
        testConnection()
    }

    private func testConnection() {
        testing = true
        CloudSyncService.shared.checkConnection { ok in
            testing = false
            connStatus = ok
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased()).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "888888")).padding(.top, 6)
    }

    private func settingRow(icon: String, title: String, value: String? = nil, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(danger ? .wosDanger : Color(hex: "9ca3af")).frame(width: 22)
                Text(title).font(.system(size: 14)).foregroundColor(danger ? .wosDanger : .white)
                Spacer()
                if let value { Text(value).font(.system(size: 12)).foregroundColor(Color(hex: "666666")) }
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(Color(hex: "444444"))
            }
            .padding(.vertical, 10)
        }
    }
}

struct WOSSmallButtonStyle: ButtonStyle {
    var ghost: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(ghost ? .wosAccent : .white)
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(ghost ? Color(hex: "1a1a1a") : Color.wosAccent)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(ghost ? Color.wosBorder : .clear))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
