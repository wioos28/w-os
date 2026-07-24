// WindowView.swift
// macOS-style window with drag constraining, double-click maximize,
// resize handle, smooth animations, and active/inactive shadow states.
import SwiftUI

struct WindowView: View {
    @ObservedObject var window: WindowInstance
    @EnvironmentObject var systemState: SystemState
    @State private var dragOffset: CGSize = .zero
    @State private var isClosing: Bool = false
    @State private var resizeOffset: CGSize = .zero

    private var isActive: Bool { systemState.frontWindowId == window.id }

    private let minWindowWidth: CGFloat = 400
    private let minWindowHeight: CGFloat = 300

    var body: some View {
        GeometryReader { geo in
            let screenSize = geo.size
            let w = window.maximized ? screenSize.width : max(window.width + resizeOffset.width, minWindowWidth)
            let h = window.maximized ? screenSize.height - 40 : max(window.height + resizeOffset.height, minWindowHeight)
            let posX = window.maximized ? screenSize.width / 2 : clampedX(window.x, width: w, screen: screenSize) + dragOffset.width
            let posY = window.maximized ? screenSize.height / 2 : clampedY(window.y, height: h, screen: screenSize) + dragOffset.height

            ZStack {
                VStack(spacing: 0) {
                    titleBar
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.wosBackground)
                }
                .frame(width: w, height: h)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
                .shadow(color: isActive ? Color.black.opacity(0.7) : Color.black.opacity(0.25),
                        radius: isActive ? 24 : 10, y: isActive ? 12 : 4)
                .opacity(isClosing ? 0 : 1)
                .scaleEffect(isClosing ? 0.92 : 1)
                .position(x: posX, y: posY)

                if !window.maximized {
                    resizeHandle(screenSize: screenSize, windowW: w, windowH: h)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        systemState.bringToFront(window.id)
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newX = window.x + value.translation.width
                        let newY = window.y + value.translation.height
                        window.x = clampedX(newX, width: window.width, screen: screenSize)
                        window.y = clampedY(newY, height: window.height, screen: screenSize)
                        dragOffset = .zero
                    }
            )
            .onTapGesture { systemState.bringToFront(window.id) }
            .onTapGesture(count: 2) {
                withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.85)) {
                    systemState.maximizeWindow(window.id)
                }
            }
            .zIndex(isActive ? 1000 : 100)
            .animation(Animation.spring(response: 0.35, dampingFraction: 0.85), value: window.maximized)
            .animation(Animation.easeInOut(duration: 0.25), value: isClosing)
        }
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack {
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 5).fill(window.color).frame(width: 18, height: 18)
                    .overlay(window.icon.view(size: 11, color: .white))
                Text(window.title).font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "cccccc"))
            }
            Spacer()
            HStack(spacing: 6) {
                winButton(systemName: "minus") { systemState.minimizeWindow(window.id) }
                winButton(systemName: "square") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        systemState.maximizeWindow(window.id)
                    }
                }
                winButton(systemName: "xmark", bg: .wosDanger, fg: .white) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        isClosing = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        systemState.closeWindow(window.id)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isActive ? Color(hex: "222222") : Color(hex: "1a1a1a"))
    }

    // MARK: - Window Buttons

    private func winButton(systemName: String, bg: Color = Color(hex: "333333"), fg: Color = Color(hex: "aaaaaa"), action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(fg)
                .frame(width: 22, height: 22)
                .background(Circle().fill(bg))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resize Handle

    @ViewBuilder
    private func resizeHandle(screenSize: CGSize, windowW: CGFloat, windowH: CGFloat) -> some View {
        GeometryReader { handleGeo in
            let handleSize: CGFloat = 20

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.4))
                        .frame(width: handleSize, height: handleSize)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    let newW = window.width + value.translation.width
                                    let newH = window.height + value.translation.height
                                    resizeOffset = CGSize(
                                        width: newW >= minWindowWidth ? value.translation.width : resizeOffset.width,
                                        height: newH >= minWindowHeight ? value.translation.height : resizeOffset.height
                                    )
                                }
                                .onEnded { value in
                                    let finalW = max(window.width + resizeOffset.width, minWindowWidth)
                                    let finalH = max(window.height + resizeOffset.height, minWindowHeight)
                                    window.width = min(finalW, screenSize.width)
                                    window.height = min(finalH, screenSize.height - 40)
                                    resizeOffset = .zero
                                }
                        )
                }
            }
            .frame(width: windowW, height: windowH)
            .position(x: windowW / 2, y: windowH / 2)
        }
        .allowsHitTesting(true)
    }

    // MARK: - Content Routing

    @ViewBuilder
    private var content: some View {
        switch window.appId {
        case "settings": SettingsAppView()
        case "browser": BrowserAppView()
        case "appstore": AppStoreAppView()
        case "terminal": TerminalAppView()
        case "files": FileManagerAppView()
        case "calculator": CalculatorAppView()
        case "notes": NotesAppView()
        case "weather": WeatherAppView()
        case "music": MusicAppView()
        case "calendar": CalendarAppView()
        case "update": UpdateAppView()
        default:
            // Check if it's an installed real app
            if let realApp = findRealApp(by: window.appId) {
                WebViewAppView(app: realApp)
            } else {
                Text("Không tìm thấy app: \(window.appId)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.wosTextMuted)
            }
        }
    }

    private func findRealApp(by id: String) -> RealApp? {
        // Search in all available real apps
        for app in RealAppsData.all {
            if app.id == id {
                return app
            }
        }
        return nil
    }

    // MARK: - Position Clamping

    private func clampedX(_ x: CGFloat, width: CGFloat, screen: CGSize) -> CGFloat {
        max(width / 2, min(x, screen.width - width / 2))
    }

    private func clampedY(_ y: CGFloat, height: CGFloat, screen: CGSize) -> CGFloat {
        max(height / 2 + 20, min(y, screen.height - height / 2))
    }
}
