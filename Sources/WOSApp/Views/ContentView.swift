// ContentView.swift
// Landscape-first desktop OS layout with side dock and horizontal windows.
import SwiftUI
import WOSCore

struct ContentView: View {
    @EnvironmentObject var systemState: WOSShellState
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            Group {
                switch systemState.screen {
                case .boot: BootView()
                case .setup: SetupView()
                case .lock: LockView()
                case .desktop: desktopLayout
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: systemState.screen)

            overlays
        }
        .onAppear {
            systemState.boot()
            rotateToLandscape()
        }
    }

    private var desktopLayout: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            if isLandscape {
                HStack(spacing: 0) {
                    StatusBarWOS(
                        onControlCenter: { systemState.showControlCenter = true },
                        onNotifications: { systemState.showNotifications = true },
                        onSearch: { systemState.showSearch = true },
                        onMultitask: { systemState.showMultitask = true },
                        isVertical: true
                    )
                    .frame(width: 44)
                    DesktopView()
                    SideDock().frame(width: 80)
                }
            } else {
                VStack(spacing: 0) {
                    StatusBarWOS(
                        onControlCenter: { systemState.showControlCenter = true },
                        onNotifications: { systemState.showNotifications = true },
                        onSearch: { systemState.showSearch = true },
                        onMultitask: { systemState.showMultitask = true },
                        isVertical: false
                    )
                    .frame(height: 44)
                    DesktopView()
                    BottomDock().frame(height: 80)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var overlays: some View {
        ZStack {
            if systemState.showControlCenter {
                ControlCenterView(onClose: { systemState.showControlCenter = false })
                    .transition(.move(edge: .trailing)).zIndex(20000)
            }
            if systemState.showNotifications {
                NotificationCenterView(onClose: { systemState.showNotifications = false })
                    .transition(.move(edge: .top)).zIndex(20000)
            }
            if systemState.showSearch {
                SearchView(onClose: { systemState.showSearch = false })
                    .transition(.opacity).zIndex(20000)
            }
            if systemState.showMultitask {
                MultitaskView(onClose: { systemState.showMultitask = false })
                    .transition(.opacity).zIndex(20000)
            }
        }
    }

    private func rotateToLandscape() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometry = windowScene.windows.first?.windowScene?.keyWindow
        geometry?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        }
    }
}

// MARK: - Side Dock (Landscape)

struct SideDock: View {
    @EnvironmentObject var systemState: WOSShellState
    @State private var showShutdown = false

    var body: some View {
        VStack(spacing: 12) {
            ForEach(SystemAppsData.dockAppIds, id: \.self) { id in
                if let app = SystemAppsData.find(id) {
                    let isOpen = systemState.windows.contains { $0.appId == id && !$0.minimized }
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isOpen ? Color.wosAccent : Color.wosPanelAlt)
                            .frame(width: 52, height: 52)
                            .overlay(app.icon.view(size: 22, color: .white))
                            .shadow(color: isOpen ? Color.wosAccent.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                        if isOpen { Circle().fill(Color.wosAccent).frame(width: 4, height: 4) }
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
            Spacer()
            VStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 14).fill(Color.wosPanelAlt).frame(width: 52, height: 52)
                    .overlay(Image(systemName: "power").font(.system(size: 20)).foregroundColor(Color.wosDanger))
            }
            .onTapGesture { showShutdown = true }
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .confirmationDialog("", isPresented: $showShutdown, titleVisibility: .visible) {
            Button(action: { systemState.screen = .lock }) { Label("Khóa máy", systemImage: "lock.fill") }
            Button(action: { systemState.rebootThenDesktop() }) { Label("Khởi động lại", systemImage: "arrow.triangle.2.circlepath") }
            Button(role: .destructive) { withAnimation { systemState.screen = .boot } } label: { Label("Tắt nguồn", systemImage: "power") }
            Button("Hủy", role: .cancel) {}
        }
    }
}

// MARK: - Bottom Dock (Portrait)

struct BottomDock: View {
    @EnvironmentObject var systemState: WOSShellState
    @State private var showShutdown = false

    var body: some View {
        HStack(spacing: 20) {
            ForEach(SystemAppsData.dockAppIds, id: \.self) { id in
                if let app = SystemAppsData.find(id) {
                    let isOpen = systemState.windows.contains { $0.appId == id && !$0.minimized }
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isOpen ? Color.wosAccent : Color.wosPanelAlt)
                            .frame(width: 50, height: 50)
                            .overlay(app.icon.view(size: 22, color: .white))
                        if isOpen { Circle().fill(Color.wosAccent).frame(width: 4, height: 4) }
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
                RoundedRectangle(cornerRadius: 14).fill(Color.wosPanelAlt).frame(width: 50, height: 50)
                    .overlay(Image(systemName: "power").font(.system(size: 20)).foregroundColor(Color.wosDanger))
            }
            .onTapGesture { showShutdown = true }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .confirmationDialog("", isPresented: $showShutdown, titleVisibility: .visible) {
            Button(action: { systemState.screen = .lock }) { Label("Khóa máy", systemImage: "lock.fill") }
            Button(action: { systemState.rebootThenDesktop() }) { Label("Khởi động lại", systemImage: "arrow.triangle.2.circlepath") }
            Button(role: .destructive) { withAnimation { systemState.screen = .boot } } label: { Label("Tắt nguồn", systemImage: "power") }
            Button("Hủy", role: .cancel) {}
        }
    }
}
