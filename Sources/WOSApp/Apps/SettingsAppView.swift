// SettingsAppView.swift
// Modern settings with numeric PIN management, privacy controls, and boot drive.
import SwiftUI
import WOSCore

struct SettingsAppView: View {
    @EnvironmentObject var systemState: WOSShellState
    @StateObject private var bootDrive = BootDriveService()

    @State private var darkMode = true
    @State private var apiUrl = ""
    @State private var testing = false
    @State private var connStatus: Bool?
    @State private var repoUrl = ""
    @State private var showResetConfirm = false
    @State private var showChangePassword = false
    @State private var oldPin = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var pinError: String?
    @State private var autoLockTimeout = "5 phút"

    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Profile card
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.wosAccent, Color.wosAccent.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 54, height: 54)
                        Text(avatarLetter)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
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
                        .onTapGesture { systemState.setWallpaper(wp.id); haptic.impactOccurred() }
                    }
                }

                sectionTitle("Hệ điều hành (Boot Drive)")
                bootDriveCard

                sectionTitle("Bảo mật")
                securityCard

                sectionTitle("Dữ liệu đám mây")
                cloudCard

                sectionTitle("Chung")
                settingRow(icon: "arrow.triangle.2.circlepath", title: "Cập nhật phần mềm") {}
                settingRow(icon: "arrow.clockwise", title: "Làm mới danh sách app", value: catalogInfo) {
                    systemState.refreshAppCatalog()
                    haptic.impactOccurred()
                }
                settingRow(icon: "moon.fill", title: "Chế độ tối", value: darkMode ? "Bật" : "Tắt") { darkMode.toggle() }
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
        .alert("Khôi phục cài đặt gốc?", isPresented: $showResetConfirm) {
            Button("Hủy", role: .cancel) {}
            Button("Khôi phục", role: .destructive) { systemState.factoryReset() }
        } message: {
            Text("Toàn bộ dữ liệu cục bộ sẽ bị xóa.")
        }
        .sheet(isPresented: $showChangePassword) {
            changePasswordSheet
        }
    }

    // MARK: - Security Card

    private var securityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            settingRow(icon: "key.fill", title: "Đổi mã PIN") { showChangePassword = true }

            HStack {
                Text("Tự động khóa").font(.system(size: 14)).foregroundColor(.white)
                Spacer()
                Menu(autoLockTimeout) {
                    ForEach(["1 phút", "5 phút", "15 phút", "30 phút", "Không bao giờ"], id: \.self) { option in
                        Button(option) { autoLockTimeout = option }
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "888888"))
            }

            HStack {
                Image(systemName: "lock.fill").font(.system(size: 15)).foregroundColor(Color(hex: "9ca3af")).frame(width: 22)
                Text("Mã PIN").font(.system(size: 14)).foregroundColor(.white)
                Spacer()
                Text("••••••").font(.system(size: 12)).foregroundColor(Color(hex: "666666"))
            }
        }
        .padding(14)
        .background(Color(hex: "111111"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    // MARK: - Change Password Sheet

    private var changePasswordSheet: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Đổi mã PIN")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    pinField(label: "PIN hiện tại", text: $oldPin)
                    pinField(label: "PIN mới (4-6 số)", text: $newPin)
                    pinField(label: "Xác nhận PIN mới", text: $confirmPin)
                }

                if let pinError {
                    Text(pinError).foregroundColor(.wosDanger).font(.system(size: 13))
                }

                Button(action: changePassword) {
                    Text("Lưu")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.wosAccent)
                        .cornerRadius(12)
                }
                .disabled(newPin.isEmpty || confirmPin.isEmpty)

                Spacer()
            }
            .padding(20)
            .background(Color.wosBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { showChangePassword = false; oldPin = ""; newPin = ""; confirmPin = ""; pinError = nil }
                        .foregroundColor(.wosAccent)
                }
            }
        }
    }

    private func pinField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12)).foregroundColor(Color(hex: "888888"))
            TextField("", text: text, prompt: Text("••••••").foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .keyboardType(.numberPad)
                .onChange(of: text.wrappedValue) { newVal in
                    text.wrappedValue = String(newVal.filter { $0.isNumber }.prefix(6))
                }
        }
    }

    private func changePassword() {
        pinError = nil
        guard oldPin == systemState.password else {
            pinError = "PIN hiện tại không đúng"; return
        }
        guard newPin.count >= 4 else {
            pinError = "PIN mới phải có ít nhất 4 số"; return
        }
        guard newPin == confirmPin else {
            pinError = "PIN xác nhận không khớp"; return
        }
        systemState.password = newPin
        UserDefaults.standard.set(newPin, forKey: "wos_password")
        showChangePassword = false
        oldPin = ""; newPin = ""; confirmPin = ""
        haptic.impactOccurred()
    }

    // MARK: - Boot Drive Card

    private var bootDriveCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hiện tại: \(systemState.bootDriveMode.label)")
                .font(.system(size: 12)).foregroundColor(Color(hex: "999999"))

            if let info = bootDrive.driveInfo {
                HStack(spacing: 12) {
                    infoItem("Phiên bản", info.version)
                    infoItem("Tác giả", info.author)
                    infoItem("Tải về", info.downloadDate.formatted(date: .abbreviated, time: .shortened))
                }
            }

            HStack(spacing: 8) {
                Button("Tải từ GitHub") {
                    guard !repoUrl.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    bootDrive.downloadFromRepo(repoUrl) { res in
                        if case .success(let info) = res { systemState.setBootDriveMode(.selfBuild(source: info.repoURL)) }
                    }
                }
                .buttonStyle(WOSSmallButtonStyle())

                Button("Admin Build") {
                    bootDrive.useAdminDrive { res in
                        if case .success = res { systemState.setBootDriveMode(.adminBuilt) }
                    }
                }
                .buttonStyle(WOSSmallButtonStyle(ghost: true))
            }

            TextField("", text: $repoUrl, prompt: Text("URL repo GitHub...").foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .autocapitalization(.none)

            if bootDrive.status != .idle { statusLine }
        }
        .padding(14)
        .background(Color(hex: "111111"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    private func infoItem(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 10)).foregroundColor(Color(hex: "666666"))
            Text(value).font(.system(size: 11, weight: .medium)).foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var statusLine: some View {
        switch bootDrive.status {
        case .idle: EmptyView()
        case .downloading:
            HStack(spacing: 6) { ProgressView().tint(.wosAccent); Text("Đang tải...").foregroundColor(Color(hex: "aaaaaa")).font(.system(size: 12)) }
        case .ready:
            HStack(spacing: 6) { Image(systemName: "checkmark.circle.fill").foregroundColor(.wosSuccess); Text("Sẵn sàng").foregroundColor(.wosSuccess).font(.system(size: 12)) }
        case .outdated:
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosWarning); Text("Cần cập nhật").foregroundColor(.wosWarning).font(.system(size: 12)) }
        case .failed(let msg):
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosDanger); Text(msg).foregroundColor(.wosDanger).font(.system(size: 12)) }
        }
    }

    // MARK: - Cloud Card

    private var cloudCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Địa chỉ server").font(.system(size: 11)).foregroundColor(Color(hex: "777777"))
            TextField("", text: $apiUrl, prompt: Text("https://server.example.com").foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .autocapitalization(.none)
            HStack(spacing: 8) {
                Button(action: saveApiUrl) {
                    HStack(spacing: 6) { Image(systemName: "square.and.arrow.down.fill"); Text("Lưu") }
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
                    Text(connStatus ? "Đã kết nối" : "Chưa kết nối")
                        .foregroundColor(connStatus ? .wosSuccess : .wosDanger).font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .padding(14)
        .background(Color(hex: "111111"))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    // MARK: - Helpers

    private var catalogInfo: String {
        if SystemAppsData.catalogLoaded {
            return "v\(SystemAppsData.catalogVersion)"
        }
        return "Mặc định"
    }

    private var avatarLetter: String {
        let n = systemState.userName
        return n.isEmpty ? "?" : String(n.prefix(1)).uppercased()
    }

    private func saveApiUrl() { CloudSyncService.shared.baseURL = apiUrl; testConnection() }
    private func testConnection() {
        testing = true
        CloudSyncService.shared.checkConnection { ok in testing = false; connStatus = ok }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased()).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "888888")).padding(.top, 6)
    }

    private func settingRow(icon: String, title: String, value: String? = nil, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: { action(); haptic.impactOccurred() }) {
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
