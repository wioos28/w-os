// SearchView.swift
// Spotlight-style search with glassmorphism and smooth animations.
import SwiftUI

struct SearchView: View {
    var onClose: () -> Void
    @EnvironmentObject var systemState: SystemState
    @State private var query = ""
    @FocusState private var focused: Bool
    @State private var selectedCategory = "Tất cả"

    private let categories = ["Tất cả", "Hệ thống", "Đã cài"]

    private struct Entry: Identifiable {
        let id: String
        let title: String
        let icon: IconRef
        let color: Color
        let isReal: Bool
        let realApp: RealApp?
    }

    private var entries: [Entry] {
        let system = SystemAppsData.list.map {
            Entry(id: "sys_\($0.id)", title: $0.title, icon: $0.icon, color: $0.color, isReal: false, realApp: nil)
        }
        let real = systemState.installedApps.map {
            Entry(id: "real_\($0.id)", title: $0.name, icon: $0.icon, color: $0.color, isReal: true, realApp: $0)
        }
        var all = system + real

        // Filter by category
        switch selectedCategory {
        case "Hệ thống": all = system
        case "Đã cài": all = real
        default: break
        }

        // Filter by search query
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.wosTextMuted)

                        TextField("", text: $query, prompt: Text("Tìm kiếm app...").foregroundColor(Color.wosTextDisabled))
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .focused($focused)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        if !query.isEmpty {
                            Button(action: { query = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.wosTextMuted)
                            }
                        }

                        Button("Hủy", action: onClose)
                            .foregroundColor(.wosAccent)
                            .font(.system(size: 15, weight: .medium))
                    }
                    .padding(12)
                    .background(Color.wosPanelAlt)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))

                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { withAnimation { selectedCategory = cat } }) {
                                    Text(cat)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(selectedCategory == cat ? .white : Color.wosTextSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(selectedCategory == cat ? Color.wosAccent : Color.wosPanelAlt)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }

                    // Results
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, e in
                                searchResultRow(e)
                                    .opacity(focused ? 1 : 0)
                                    .offset(y: focused ? 0 : 10)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.03), value: focused)
                            }

                            if entries.isEmpty && !query.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.wosTextDisabled)
                                    Text("Không tìm thấy kết quả")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.wosTextMuted)
                                }
                                .padding(.top, 40)
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.top, 50)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                )
                .frame(maxHeight: geo.size.height * 0.75)

                Spacer()
            }
        }
        .background(Color.black.opacity(0.5).onTapGesture(perform: onClose))
        .onAppear { focused = true }
    }

    // MARK: - Result Row

    private func searchResultRow(_ e: Entry) -> some View {
        Button(action: { select(e) }) {
            HStack(spacing: 12) {
                // Icon
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [e.color, e.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(e.icon.view(size: 18, color: .white))

                // Title
                Text(e.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                // Arrow
                if e.isReal {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.wosTextDisabled)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
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

// MARK: - Corner Radius Extension

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

#Preview {
    SearchView(onClose: {})
        .environmentObject(SystemState())
}
