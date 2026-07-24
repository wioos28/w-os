// StatusBarWOS.swift
// Ported 1:1 from src/components/StatusBarWOS.js
import SwiftUI

struct StatusBarWOS: View {
    var onControlCenter: () -> Void
    var onNotifications: () -> Void
    var onSearch: () -> Void
    var onMultitask: () -> Void

    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var timeString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm"
        return f.string(from: now)
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: onNotifications) {
                    Image(systemName: "bell.fill").font(.system(size: 13)).foregroundColor(.white)
                }
                .frame(width: 60, alignment: .leading)

                Button(action: onSearch) {
                    Text(timeString).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in onMultitask() })
                .frame(maxWidth: .infinity)

                Button(action: onControlCenter) {
                    HStack(spacing: 5) {
                        Image(systemName: "wifi").font(.system(size: 12)).foregroundColor(.white)
                        Image(systemName: "antenna.radiowaves.left.and.right").font(.system(size: 12)).foregroundColor(.white)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).stroke(Color.white, lineWidth: 1).frame(width: 18, height: 9)
                            RoundedRectangle(cornerRadius: 1).fill(Color(hex: "4ade80")).frame(width: 13, height: 6).padding(.leading, 1.5)
                        }
                        Text("85%").font(.system(size: 10)).foregroundColor(.white)
                    }
                }
                .frame(width: 110, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
            Spacer()
        }
        .onReceive(timer) { now = $0 }
        .zIndex(9999)
    }
}
