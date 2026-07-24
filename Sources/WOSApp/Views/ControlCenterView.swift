// ControlCenterView.swift
// Modern glassmorphism control center with rounded tiles and smooth animations.
import SwiftUI
import WOSCore

private struct QuickToggle: Identifiable {
    let id: String
    let label: String
    let symbol: String
    var active: Bool = false
    let color: Color
}

struct ControlCenterView: View {
    var onClose: () -> Void
    @State private var toggles: [QuickToggle] = [
        QuickToggle(id: "airplane", label: "Máy bay", symbol: "airplane", color: .orange),
        QuickToggle(id: "wifi", label: "Wi-Fi", symbol: "wifi", active: true, color: .wosAccent),
        QuickToggle(id: "bluetooth", label: "Bluetooth", symbol: "b.circle.fill", active: true, color: .wosAccent),
        QuickToggle(id: "cellular", label: "Dữ liệu", symbol: "antenna.radiowaves.left.and.right", active: true, color: .wosSuccess),
        QuickToggle(id: "flashlight", label: "Đèn flash", symbol: "flashlight.off.fill", color: .white),
        QuickToggle(id: "dnd", label: "Im lặng", symbol: "moon.fill", color: .purple),
        QuickToggle(id: "rotate", label: "Xoay", symbol: "lock.rotation", active: true, color: .wosAccent),
        QuickToggle(id: "saver", label: "Pin", symbol: "battery.50percent", color: .green),
    ]
    @State private var brightness: Double = 0.5
    @State private var volume: Double = 0.5

    private let gridColumns = [GridItem(.adaptive(minimum: 70), spacing: 10)]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 16) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 4)

                // Quick toggles grid
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(toggles) { t in toggleTile(t) }
                }

                // Sliders
                VStack(spacing: 12) {
                    sliderRow(icon: "sun.max.fill", value: $brightness, label: "Độ sáng")
                    sliderRow(icon: "speaker.wave.2.fill", value: $volume, label: "Âm lượng")
                }

                // Settings link
                Button(action: LinkingService.openSystemSettings) {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14))
                        Text("Cài đặt")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.wosAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.wosAccent.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .padding(.bottom, 30)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.95)
            )
            .padding(.horizontal, 10)
        }
    }

    // MARK: - Toggle Tile

    private func toggleTile(_ t: QuickToggle) -> some View {
        let active = toggles.first(where: { $0.id == t.id })?.active ?? false
        return VStack(spacing: 5) {
            Image(systemName: t.symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(active ? .white : Color.wosTextSecondary)

            Text(t.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(active ? .white : Color.wosTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 74, height: 74)
        .background(
            ZStack {
                if active {
                    LinearGradient(
                        colors: [t.color, t.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.wosPanelAlt
                }
            }
        )
        .cornerRadius(16)
        .shadow(color: active ? t.color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        .onTapGesture { toggle(t.id) }
        .onLongPressGesture(minimumDuration: 0.5) { LinkingService.openSystemSettings() }
    }

    private func toggle(_ id: String) {
        guard let idx = toggles.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            toggles[idx].active.toggle()
        }
    }

    // MARK: - Slider Row

    private func sliderRow(icon: String, value: Binding<Double>, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.wosTextSecondary)
                .frame(width: 20)

            Slider(value: value, in: 0...1)
                .tint(.wosAccent)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ControlCenterView(onClose: {})
}
