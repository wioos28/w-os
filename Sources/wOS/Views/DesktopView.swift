// DesktopView.swift
// Ported 1:1 from src/screens/DesktopScreen.js (app grid, dock, shutdown
// modal, delete-app confirm) plus rendering the floating WindowView stack.
import SwiftUI

struct DesktopView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var showShutdown = false
    @State private var appToDelete: RealApp?

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
                                .onTapGesture { systemState.openApp(app.id) }
                        }
                        ForEach(systemState.installedApps) { app in
                            appIconView(title: app.name, icon: app.icon, color: app.color, isReal: true)
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
        .confirmationDialog("Tùy chọn nguồn", isPresented: $showShutdown, titleVisibility: .visible) {
            Button("Khóa máy") { systemState.screen = .lock }
            Button("Khởi động lại") { systemState.rebootThenDesktop() }
            Button("Tắt nguồn", role: .destructive) { showShutdown = false }
            Button("Hủy", role: .cancel) {}
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
                    .fill(color)
                    .frame(width: 62, height: 62)
                    .overlay(icon.view(size: 26, color: .white))
                if isReal {
                    Circle().fill(Color.black.opacity(0.6)).frame(width: 16, height: 16)
                        .overlay(Image(systemName: "arrow.up.right").font(.system(size: 8)).foregroundColor(.white))
                        .offset(x: 4, y: -4)
                }
            }
            Text(title).font(.system(size: 11)).foregroundColor(.white).lineLimit(1)
        }
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
