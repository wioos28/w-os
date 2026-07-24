// SearchView.swift
// Ported 1:1 from src/screens/SearchScreen.js — spotlight-style search across
// BOTH built-in system apps AND every installed real app.
import SwiftUI
import UIKit

struct SearchView: View {
    var onClose: () -> Void
    @EnvironmentObject var systemState: SystemState
    @State private var query = ""
    @FocusState private var focused: Bool

    private struct Entry: Identifiable {
        let id: String
        let title: String
        let icon: IconRef
        let color: Color
        let isReal: Bool
        let realApp: RealApp?
    }

    private var entries: [Entry] {
        let system = SystemAppsData.list.map { Entry(id: "sys_\($0.id)", title: $0.title, icon: $0.icon, color: $0.color, isReal: false, realApp: nil) }
        let real = systemState.installedApps.map { Entry(id: "real_\($0.id)", title: $0.name, icon: $0.icon, color: $0.color, isReal: true, realApp: $0) }
        let all = system + real
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "666666"))
                        TextField("", text: $query, prompt: Text("Tìm kiếm app...").foregroundColor(Color(hex: "555555")))
                            .foregroundColor(.white)
                            .focused($focused)
                            .autocapitalization(.none)
                        Button("Hủy", action: onClose).foregroundColor(.wosAccent).font(.system(size: 14))
                    }
                    .padding(10)
                    .background(Color(hex: "1a1a1a"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.wosBorder))

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(entries) { e in
                                HStack {
                                    RoundedRectangle(cornerRadius: 8).fill(e.color).frame(width: 30, height: 30)
                                        .overlay(e.icon.view(size: 16, color: .white))
                                    Text(e.title).font(.system(size: 15)).foregroundColor(.white)
                                    Spacer()
                                    if e.isReal { Image(systemName: "arrow.up.right").font(.system(size: 12)).foregroundColor(Color(hex: "555555")) }
                                }
                                .padding(.vertical, 10)
                                .overlay(Divider().background(Color.wosPanelAlt), alignment: .bottom)
                                .onTapGesture { select(e) }
                            }
                            if entries.isEmpty {
                                Text("Không tìm thấy kết quả").foregroundColor(Color(hex: "555555")).padding(.top, 20)
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.top, 40)
                .background(Color.black.opacity(0.97))
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .frame(maxHeight: geo.size.height * 0.7)
                Spacer()
            }
        }
        .background(Color.black.opacity(0.5).onTapGesture(perform: onClose))
        .onAppear { focused = true }
    }

    private func select(_ e: Entry) {
        if e.isReal, let app = e.realApp {
            LinkingService.openRealApp(app)
        } else {
            systemState.openApp(String(e.id.dropFirst(4)))
        }
        onClose()
    }
}

// Helper for rounding only specific corners (used above), since SwiftUI's
// stock cornerRadius rounds all four corners.
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
