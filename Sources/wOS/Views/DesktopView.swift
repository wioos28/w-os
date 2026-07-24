// DesktopView.swift
// Landscape-optimized desktop with adaptive grid and no built-in dock.
import SwiftUI

struct DesktopView: View {
    @EnvironmentObject var systemState: SystemState
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var appToDelete: RealApp?
    @State private var pressedAppId: String?
    @State private var hasAppeared = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let fixedColumns = isLandscape
                ? [GridItem(.fixed(90), spacing: 24),
                   GridItem(.fixed(90), spacing: 24),
                   GridItem(.fixed(90), spacing: 24)]
                : [GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 18)]

            ZStack {
                WallpaperBackground(wallpaperId: systemState.wallpaper)

                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVGrid(columns: fixedColumns, spacing: isLandscape ? 28 : 22) {
                        // System apps
                        ForEach(SystemAppsData.list) { app in
                            appIconView(title: app.title, icon: app.icon, color: app.color, isReal: false, isLandscape: isLandscape)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(SystemAppsData.list.firstIndex(where: { $0.id == app.id }) ?? 0) * 0.05), value: hasAppeared)
                                .onTapGesture { systemState.openApp(app.id) }
                        }

                        // Installed apps - open within W OS
                        ForEach(systemState.installedApps) { app in
                            appIconView(title: app.name, icon: app.icon, color: app.color, isReal: true, isLandscape: isLandscape)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: hasAppeared)
                                .onTapGesture { systemState.openApp(app.id) }
                                .onLongPressGesture { appToDelete = app }
                        }
                    }
                    .padding(isLandscape ? EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24) : EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                }

                // Windows
                ForEach(systemState.windows.filter { !$0.minimized }) { win in
                    WindowView(window: win)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { hasAppeared = true }
        }
        .alert("Xóa \(appToDelete?.name ?? "")?", isPresented: Binding(get: { appToDelete != nil }, set: { if !$0 { appToDelete = nil } })) {
            Button("Hủy", role: .cancel) { appToDelete = nil }
            Button("Xóa", role: .destructive) {
                if let app = appToDelete { systemState.uninstallApp(app) }
                appToDelete = nil
            }
        }
    }

    // MARK: - App Icon

    private func appIconView(title: String, icon: IconRef, color: Color, isReal: Bool, isLandscape: Bool) -> some View {
        let iconSize: CGFloat = isLandscape ? 68 : 62
        let iconFrame: CGFloat = isLandscape ? 72 : 66

        return VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: iconSize, height: iconSize)
                    .shadow(color: color.opacity(0.35), radius: 10, x: 0, y: 6)
                    .overlay(icon.view(size: iconSize * 0.42, color: .white))
                    .scaleEffect(pressedAppId == (isReal ? title : icon.symbol) ? 0.88 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: pressedAppId)

                if isReal {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 16, height: 16)
                        .overlay(Image(systemName: "arrow.up.right").font(.system(size: 8)).foregroundColor(.white))
                        .offset(x: 5, y: -5)
                }
            }
            Text(title)
                .font(.system(size: isLandscape ? 12 : 11, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: iconFrame)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            pressedAppId = pressing ? (isReal ? title : icon.symbol) : nil
        }, perform: {})
    }
}

#Preview {
    DesktopView()
        .environmentObject(SystemState())
}
