// ControlCenterView.swift
// Ported 1:1 from src/screens/ControlCenter.js — Wi-Fi/Bluetooth/Airplane
// mode can never be toggled by a third-party app on iOS (an OS security
// restriction, not a W OS limitation), so these stay quick-glance UI state;
// long-pressing one performs a REAL action: opening the phone's actual
// Settings app via LinkingService.openSystemSettings().
import SwiftUI

private struct QuickToggle: Identifiable {
    let id: String
    let label: String
    let symbol: String
    var active: Bool = false
}

struct ControlCenterView: View {
    var onClose: () -> Void
    @State private var toggles: [QuickToggle] = [
        QuickToggle(id: "airplane", label: "Chế độ máy bay", symbol: "airplane"),
        QuickToggle(id: "wifi", label: "Wi-Fi", symbol: "wifi", active: true),
        QuickToggle(id: "bluetooth", label: "Bluetooth", symbol: "b.circle.fill", active: true),
        QuickToggle(id: "cellular", label: "Dữ liệu", symbol: "antenna.radiowaves.left.and.right", active: true),
        QuickToggle(id: "flashlight", label: "Đèn flash", symbol: "flashlight.off.fill"),
        QuickToggle(id: "dnd", label: "Im lặng", symbol: "moon.fill"),
        QuickToggle(id: "rotate", label: "Xoay", symbol: "lock.rotation", active: true),
        QuickToggle(id: "saver", label: "Tiết kiệm pin", symbol: "battery.50"),
    ]
    @State private var brightness: Double = 0.5
    @State private var volume: Double = 0.5

    private let gridColumns = [GridItem(.adaptive(minimum: 70), spacing: 10)]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3).ignoresSafeArea().onTapGesture(perform: onClose)

            VStack(spacing: 16) {
                Capsule().fill(Color(hex: "444444")).frame(width: 36, height: 4)
                Text("Trung tâm điều khiển").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)

                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(toggles) { t in toggleTile(t) }
                }

                sliderBox(title: "Độ sáng", systemImage: "sun.max.fill", value: $brightness) { _ in }
                sliderBox(title: "Âm lượng", systemImage: "speaker.wave.2.fill", value: $volume, onChange: nil)

                Button(action: LinkingService.openSystemSettings) {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill").font(.system(size: 13))
                        Text("Mở Cài đặt hệ thống thật").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.wosAccent)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .padding(.bottom, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 8)
        }
    }

    private func toggleTile(_ t: QuickToggle) -> some View {
        let active = toggles.first(where: { $0.id == t.id })?.active ?? false
        return VStack(spacing: 4) {
            Image(systemName: t.symbol).font(.system(size: 20)).foregroundColor(active ? .white : Color(hex: "888888"))
            Text(t.label).font(.system(size: 9)).foregroundColor(active ? .white : Color(hex: "888888")).multilineTextAlignment(.center)
        }
        .frame(width: 74, height: 74)
        .background(active ? Color.wosAccent : Color(hex: "222222"))
        .cornerRadius(14)
        .onTapGesture { toggle(t.id) }
        .onLongPressGesture(minimumDuration: 0.45) { LinkingService.openSystemSettings() }
    }

    private func toggle(_ id: String) {
        guard let idx = toggles.firstIndex(where: { $0.id == id }) else { return }
        toggles[idx].active.toggle()
    }

    private func sliderBox(title: String, systemImage: String, value: Binding<Double>, onChange: ((Double) -> Void)?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: systemImage).font(.system(size: 13)).foregroundColor(Color(hex: "aaaaaa"))
                Text(title).font(.system(size: 12)).foregroundColor(Color(hex: "aaaaaa"))
            }
            Slider(value: value, in: 0...1, onEditingChanged: { _ in onChange?(value.wrappedValue) })
                .tint(.wosAccent)
        }
    }
}
