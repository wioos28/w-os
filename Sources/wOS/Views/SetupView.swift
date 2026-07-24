// SetupView.swift
// Modern setup wizard with slide transitions, numeric PIN, and progress bar.
import SwiftUI
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
    @State private var stepDirection: Bool = true

    private let totalSteps = 6
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ZStack {
            WallpaperBackground(wallpaperId: selectedWallpaper, dim: 0.55)

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("W OS").font(.system(size: 36, weight: .bold)).foregroundColor(.white)
                    Text("Thiết lập hệ thống").font(.system(size: 14)).foregroundColor(Color(hex: "aaaaaa"))
                }
                .padding(.top, 60)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.wosAccent)
                            .frame(width: geo.size.width * progressValue, height: 6)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 40)
                .padding(.top, 30)

                // Step content
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    stepContent
                        .transition(.asymmetric(
                            insertion: .move(edge: stepDirection ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: stepDirection ? .leading : .trailing).combined(with: .opacity)
                        ))
                        .id(step)

                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.wosDanger).font(.system(size: 13))
                            .transition(.opacity)
                    }

                    Button(action: handleNext) {
                        HStack(spacing: 8) {
                            Text(step == totalSteps ? "Hoàn tất" : "Tiếp theo")
                            if step < totalSteps {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.wosAccent, Color.wosAccent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.wosAccent.opacity(0.3), radius: 10, x: 0, y: 4)
                    }

                    if step > 1 {
                        Button("Quay lại") {
                            haptic.impactOccurred()
                            withAnimation { stepDirection = false; step -= 1; errorMessage = nil }
                        }
                        .foregroundColor(Color(hex: "888888"))
                        .font(.system(size: 14))
                    }
                }
                .padding(24)
                .frame(maxWidth: 420)
                .background(Color.black.opacity(0.55))
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08)))

                Spacer()
            }
            .padding(20)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
    }

    private var progressValue: CGFloat {
        CGFloat(step) / CGFloat(totalSteps)
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
            numericPinGroup(label: "Tạo mã PIN (4-6 số)", text: $password, placeholder: "Nhập PIN...")
            numericPinGroup(label: "Xác nhận mã PIN", text: $confirmPassword, placeholder: "Nhập lại PIN...")
            if !password.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(i < password.count ? Color.wosAccent : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                    Text(passwordStrength)
                        .font(.system(size: 11))
                        .foregroundColor(passwordStrengthColor)
                        .padding(.leading, 8)
                }
            }
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
                    .onTapGesture { selectedWallpaper = wp.id; haptic.impactOccurred() }
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

    private var passwordStrength: String {
        if password.count < 4 { return "Quá ngắn" }
        if password.count < 5 { return "Yếu" }
        if password.count == 6 { return "Mạnh" }
        return "Trung bình"
    }

    private var passwordStrengthColor: Color {
        if password.count < 4 { return .wosDanger }
        if password.count < 5 { return .wosWarning }
        return .wosSuccess
    }

    @ViewBuilder
    private var bootStatusRow: some View {
        switch bootDrive.status {
        case .idle: EmptyView()
        case .downloading:
            HStack(spacing: 6) { ProgressView().tint(.wosAccent); Text("Đang tải boot drive...").foregroundColor(Color(hex: "aaaaaa")).font(.system(size: 12)) }
        case .ready:
            HStack(spacing: 6) { Image(systemName: "checkmark.circle.fill").foregroundColor(.wosSuccess); Text("Boot drive đã sẵn sàng").foregroundColor(.wosSuccess).font(.system(size: 12)) }
        case .outdated:
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosWarning); Text("Boot drive cần cập nhật").foregroundColor(.wosWarning).font(.system(size: 12)) }
        case .failed(let msg):
            HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.wosDanger); Text(msg).foregroundColor(.wosDanger).font(.system(size: 12)) }
        }
    }

    // MARK: - Field Groups

    private func fieldGroup(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).foregroundColor(Color(hex: "888888")).font(.system(size: 13))
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .keyboardType(keyboard)
        }
    }

    private func numericPinGroup(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).foregroundColor(Color(hex: "888888")).font(.system(size: 13))
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color(hex: "555555")))
                .textFieldStyle(WOSTextFieldStyle())
                .keyboardType(.numberPad)
                .onChange(of: text.wrappedValue) { newVal in
                    text.wrappedValue = String(newVal.filter { $0.isNumber }.prefix(6))
                }
        }
    }

    private func bootChoiceButton(title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { action(); haptic.impactOccurred() }) {
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

    // MARK: - Actions

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            bootDrive.downloadFromRepo(url.lastPathComponent) { res in
                switch res {
                case .success(let info): systemState.setBootDriveMode(.selfBuild(source: info.repoURL)); buildError = nil
                case .failure(let err): buildError = err.localizedDescription
                }
            }
        case .failure(let err):
            buildError = err.localizedDescription
        }
    }

    private func handleNext() {
        errorMessage = nil
        haptic.impactOccurred()
        stepDirection = true

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
            guard password.count >= 4 else { errorMessage = "PIN phải có ít nhất 4 số"; return }
            guard password == confirmPassword else { errorMessage = "PIN không khớp"; return }
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
                    finishSetup(); return
                }
                guard !repoUrl.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errorMessage = "Vui lòng nhập URL repo hoặc tải file lên"; return
                }
                bootDrive.downloadFromRepo(repoUrl) { res in
                    switch res {
                    case .success(let info):
                        systemState.setBootDriveMode(.selfBuild(source: info.repoURL))
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
