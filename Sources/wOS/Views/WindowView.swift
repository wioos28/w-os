// WindowView.swift
// Ported 1:1 from src/components/Window.js — draggable floating window with
// a title bar (min/max/close), routing its content to the right app screen
// (matches the COMPONENTS map that used to live in App.js).
import SwiftUI

struct WindowView: View {
    @ObservedObject var window: WindowInstance
    @EnvironmentObject var systemState: SystemState
    @State private var dragOffset: CGSize = .zero

    private var isActive: Bool { systemState.frontWindowId == window.id }

    var body: some View {
        GeometryReader { geo in
            let screenSize = geo.size
            let w = window.maximized ? screenSize.width : window.width
            let h = window.maximized ? screenSize.height - 40 : window.height
            let posX = window.maximized ? screenSize.width / 2 : window.x + w / 2 + dragOffset.width
            let posY = window.maximized ? screenSize.height / 2 : window.y + h / 2 + dragOffset.height

        VStack(spacing: 0) {
            titleBar
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.wosBackground)
        }
        .frame(width: w, height: h)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
        .opacity(isActive ? 1 : 0.9)
        .position(x: posX, y: posY)
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    window.x += value.translation.width
                    window.y += value.translation.height
                    dragOffset = .zero
                }
        )
        .onTapGesture { systemState.bringToFront(window.id) }
        .zIndex(isActive ? 1000 : 100)
        }
    }

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
                winButton(systemName: "square") { systemState.maximizeWindow(window.id) }
                winButton(systemName: "xmark", bg: .wosDanger, fg: .white) { systemState.closeWindow(window.id) }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isActive ? Color(hex: "222222") : Color(hex: "1a1a1a"))
    }

    private func winButton(systemName: String, bg: Color = Color(hex: "333333"), fg: Color = Color(hex: "aaaaaa"), action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(fg)
                .frame(width: 22, height: 22)
                .background(Circle().fill(bg))
        }
    }

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
            Text("Không tìm thấy app: \(window.appId)").foregroundColor(.wosMuted)
        }
    }
}
