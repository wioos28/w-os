// SetupView.swift
// Ported from src/screens/SetupScreen.js (steps 1-4: name / age / password /
// wallpaper) PLUS the new post-setup boot-drive choice the user asked for:
// step 5 lets them pick "Tự boot drive riêng (Tự Build)" or
// "Chạy drive do Admin build"; step 6 (only for self-build) lets them enter
// a repo URL to read source code from, or import an uploaded file, to build
// the OS boot drive.
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SetupView: View {
    @EnvironmentObject var systemState: SystemState
    @StateObject private var bootDrive = BootDriveService()

    @State private var step = 1
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedWallpaper = "default"
    @State private var repoUrl = ""
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var buildError: String?

    private let totalSteps = 6

    var body: some View {
        ZStack {
            WallpaperBackground(wallpaperId: selectedWallpaper, dim: 0.55)

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("W OS").font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                        Text("Thiết lập hệ thống").font(.system(size: 14)).foregroundColor(Color(hex: "aaaaaa"))
                    }

                    HStack(spacing: 8) {
                        ForEach(1...totalSteps, id: \.self) { s in
                            Circle()
                                .fill(step >= s ? Color.wosAccent : Color.white.opacity(0.25))
                                .frame(width: 8, height: 8)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        stepContent

                        if let errorMessage {
                            Text(errorMessage).foregroundColor(.wosDanger).font(.system(size: 13))
                        }

                        Button(action: handleNext) {
                            Text(step == totalSteps ? "Hoàn tất" : "Tiếp theo")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.wosAccent)
                                .cornerRadius(14)
                        }
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08)))
                }
                .padding(20)
                .frame(maxWidth: 420)
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1:
            fieldGroup(label: "Họ", text: $lastName, placeholder: "Nhập họ...")
            fieldGroup(label: "Tên", text: $firstName, placeholder: "Nhập tên...")
        case 2:
            fieldGroup(label: "Xác minh độ tuổi", text: $age, placeholder: "Nhập tuổi...", keyboard: .numberPad)
        case 3:
            secureFieldGroup(label: "Tạo mật khẩu", text: $password, placeholder: "Nhập mật khẩu...")
            secureFieldGroup(label: "Xác nhận mật khẩu", text: $confirmPassword, placeholder: "Xác nhận mật khẩu...")
        case 4:
            Text("Chọn hình nền").foregroundColor(Color(hex: "bbbbbb")).font(.system(size: 13))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 10) {
                ForEach(WallpaperCatalog.all) { wp in
                    VStack(spacing: 4) {
                        WallpaperBackground(wallpaperId: wp.id, dim: 0.1)
                            .frame(width: 55, height: 75)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedWallpaper == wp.id ? Color.wosAccent : .clear, lineWidth: 2))
                        Text(wp.label).font(.system(size: 11)).foregroundColor(Color(hex: "888888"))
                    }
                    .onTapGesture { selectedWallpaper = wp.id }
                }
            }
        case 5:
            Text("Chọn cách khởi động hệ điều hành").foregroundColor(Color(hex: "bbbbbb")).font(.system(size: 13))
            bootChoiceButton(title: "1. Tự boot drive riêng (Tự Build)", subtitle: "Đọc mã nguồn từ repo hoặc tải file để tự build",
                             selected: isSelfBuildMode) {
                systemState.setBootDriveMode(.selfBuild(source: ""))
            }
            bootChoiceButton(title: "2. Chạy drive do Admin build", subtitle: "Dùng bản boot image admin đã build sẵn",
                             selected: systemState.bootDriveMode == .adminBuilt) {
                systemState.setBootDriveMode(.adminBuilt)
            }
        case 6:
            if isSelfBuildMode {
                Text("Tự build hệ điều hành").foregroundColor(Color(hex: "bbbbbb")).font(.system(size: 13))
                TextField("", text: $repoUrl, prompt: Text("Nhập URL repo (GitHub/GitLab)...").foregroundColor(Color(hex: "555555")))
                    .textFieldStyle(WOSTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Button(action: { showFileImporter = true }) {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill")
                        Text("...hoặc tự tải lên file mã nguồn")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.wosAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.wosPanelAlt)
                    .cornerRadius(10)
                }
                .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.zip, .item], onCompletion: handleFileImport)

                bootStatusRow
                if let buildError { Text(buildError).foregroundColor(.wosDanger).font(.system(size: 12)) }
            } else {
                Text("Hệ thống sẽ khởi động bằng drive OS do Admin build sẵn.")
                    .foregroundColor(Color(hex: "bbbbbb")).font(.system(size: 13))
                bootStatusRow
            }
        default:
            EmptyView()
        }
    }

    private var isSelfBuildMode: Bool {
        if case .selfBuild = systemState.bootDriveMode { return true }
        return false
    }

    @ViewBuilder
    private var bootStatusRow: some View {
        switch bootDrive.status {
        case .idle: EmptyView()
        case .cloning:
            HStack(spacing: 6) { ProgressView().tint(.wosAccent); Text("Đang đọc mã nguồn từ repo...").foregroundColor(Color(hex: "aaaaaa")).font(.system(size: 12)) }
        case .building:
            HStack(spacing: 6) { ProgressView().tint(.wosAccent); Text("Đang build boot drive (\(Int(bootDrive.progress * 100))%)...").foregroundColor(Color(hex: "aaaaaa")).font(.system(size: 12)) }
        case .ready:
            HStack(spacing: 6) { Image(systemName: "checkmark.circle.fill").foregroundColor(.wosSuccess); Text("Boot drive đã sẵn sàng").foregroundColor(.wosSuccess).font(.system(size: 12)) }
        case .failed(let msg):
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosDanger); Text(msg).foregroundColor(.wosDanger).font(.system(size: 12)) }
        }
    }

    private func fieldGroup(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).foregroundColor(Color(hex: "888888")).font(.system(size: 13))
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .keyboardType(keyboard)
        }
    }

    private func secureFieldGroup(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).foregroundColor(Color(hex: "888888")).font(.system(size: 13))
            SecureField("", text: text, prompt: Text(placeholder).foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
        }
    }

    private func bootChoiceButton(title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 11)).foregroundColor(Color(hex: "999999"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(selected ? Color.wosAccent.opacity(0.25) : Color.wosPanelAlt)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.wosAccent : Color.wosBorder, lineWidth: 1.5))
            .cornerRadius(12)
        }
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            bootDrive.buildFromUploadedFile(named: url.lastPathComponent) { res in
                switch res {
                case .success(let name): systemState.setBootDriveMode(.selfBuild(source: name)); buildError = nil
                case .failure(let err): buildError = err.localizedDescription
                }
            }
        case .failure(let err):
            buildError = err.localizedDescription
        }
    }

    private func handleNext() {
        errorMessage = nil
        switch step {
        case 1:
            guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
                  !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Vui lòng nhập đầy đủ họ và tên"; return
            }
            step = 2
        case 2:
            guard let ageNum = Int(age), ageNum > 0, ageNum <= 120 else {
                errorMessage = "Vui lòng nhập tuổi hợp lệ"; return
            }
            step = 3
        case 3:
            guard password.count >= 4 else { errorMessage = "Mật khẩu phải có ít nhất 4 ký tự"; return }
            guard password == confirmPassword else { errorMessage = "Mật khẩu không khớp"; return }
            step = 4
        case 4:
            step = 5
        case 5:
            step = 6
            if !isSelfBuildMode {
                bootDrive.useAdminDrive { _ in }
            }
        case 6:
            if isSelfBuildMode {
                if case .selfBuild(let existingSource) = systemState.bootDriveMode, !existingSource.isEmpty {
                    finishSetup()
                    return
                }
                guard !repoUrl.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errorMessage = "Vui lòng nhập URL repo hoặc tải file lên"; return
                }
                bootDrive.buildFromRepo(repoUrl) { res in
                    switch res {
                    case .success(let source):
                        systemState.setBootDriveMode(.selfBuild(source: source))
                        finishSetup()
                    case .failure(let err):
                        buildError = err.localizedDescription
                    }
                }
            } else {
                finishSetup()
            }
        default:
            break
        }
    }

    private func finishSetup() {
        systemState.completeSetup(firstName: firstName, lastName: lastName, age: age,
                                   password: password, wallpaper: selectedWallpaper)
        systemState.screen = .desktop
    }
}

struct WOSTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color.wosBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.wosBorder))
    }
}
