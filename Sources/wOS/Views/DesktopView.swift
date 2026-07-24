// DesktopView.swift
// Modern desktop with staggered animations, 3D icon press, dock magnification, and shutdown options.
import SwiftUI

struct DesktopView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var showShutdown = false
    @State private var appToDelete: RealApp?
    @State private var pressedAppId: String?
    @State private var hasAppeared = false

    private let columns = [GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 18)]

    var body: some View {
        ZStack {
            WallpaperBackground(wallpaperId: systemState.wallpaper)

            VStack(spacing: 0) {
                Spacer().frame(height: 46)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 22) {
                        ForEach(SystemAppsData.list) { app in
                            appIconView(title: app.title, icon: app.icon, color: app.color, isReal: false)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(SystemAppsData.list.firstIndex(where: { $0.id == app.id }) ?? 0) * 0.05), value: hasAppeared)
                                .onTapGesture { systemState.openApp(app.id) }
                        }
                        ForEach(systemState.installedApps) { app in
                            appIconView(title: app.name, icon: app.icon, color: app.color, isReal: true)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: hasAppeared)
                                .onTapGesture { LinkingService.openRealApp(app) }
                                .onLongPressGesture { appToDelete = app }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                dock
            }

            ForEach(systemState.windows.filter { !$0.minimized }) { win in
                WindowView(window: win)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { hasAppeared = true }
        }
        .confirmationDialog("", isPresented: $showShutdown, titleVisibility: .visible) {
            Button(action: { systemState.screen = .lock }) {
                Label("Khóa máy", systemImage: "lock.fill")
            }
            Button(action: { systemState.rebootThenDesktop() }) {
                Label("Khởi động lại", systemImage: "arrow.triangle.2.circlepath")
            }
            Button(action: { withAnimation { systemState.screen = .boot } }, role: .destructive) {
                Label("Tắt nguồn", systemImage: "power")
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Chọn thao tác nguồn")
        }
        .alert("Xóa \(appToDelete?.name ?? "")?", isPresented: Binding(get: { appToDelete != nil }, set: { if !$0 { appToDelete = nil } })) {
            Button("Hủy", role: .cancel) { appToDelete = nil }
            Button("Xóa", role: .destructive) {
                if let app = appToDelete { systemState.uninstallApp(app) }
                appToDelete = nil
            }
        }
    }

    private func appIconView(title: String, icon: IconRef, color: Color, isReal: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(icon.view(size: 26, color: .white))
                    .scaleEffect(pressedAppId == (isReal ? title : icon.symbol) ? 0.88 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: pressedAppId)
                if isReal {
                    Circle().fill(Color.black.opacity(0.6)).frame(width: 16, height: 16)
                        .overlay(Image(systemName: "arrow.up.right").font(.system(size: 8)).foregroundColor(.white))
                        .offset(x: 4, y: -4)
                }
            }
            Text(title).font(.system(size: 11)).foregroundColor(.white).lineLimit(1)
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            pressedAppId = pressing ? (isReal ? title : icon.symbol) : nil
        }, perform: {})
    }

    private var dock: some View {
        HStack(spacing: 22) {
            ForEach(SystemAppsData.dockAppIds, id: \.self) { id in
                if let app = SystemAppsData.find(id) {
                    let isOpen = systemState.windows.contains { $0.appId == id && !$0.minimized }
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isOpen ? Color.wosAccent : Color.wosPanelAlt)
                            .frame(width: 46, height: 46)
                            .overlay(app.icon.view(size: 20, color: .white))
                        if isOpen { Circle().fill(Color.white).frame(width: 4, height: 4) }
                    }
                    .onTapGesture {
                        if let win = systemState.windows.first(where: { $0.appId == id }) {
                            systemState.bringToFront(win.id)
                        } else {
                            systemState.openApp(id)
                        }
                    }
                }
            }
            VStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 12).fill(Color.wosPanelAlt).frame(width: 46, height: 46)
                    .overlay(Image(systemName: "power").font(.system(size: 20)).foregroundColor(Color(hex: "f87171")))
                Color.clear.frame(width: 4, height: 4)
            }
            .onTapGesture { showShutdown = true }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        .padding(.bottom, 18)
    }
}
