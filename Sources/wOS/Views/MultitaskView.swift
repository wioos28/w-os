// MultitaskView.swift
// Ported 1:1 from src/screens/MultitaskScreen.js — horizontal app-switcher cards.
import SwiftUI

struct MultitaskView: View {
    var onClose: () -> Void
    @EnvironmentObject var systemState: SystemState

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("Đa nhiệm").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if systemState.windows.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "square.grid.2x2").font(.system(size: 28)).foregroundColor(Color(hex: "444444"))
                                Text("Không có app nào đang chạy").foregroundColor(Color(hex: "666666")).font(.system(size: 14))
                            }
                            .frame(width: 300)
                            .padding(.vertical, 30)
                        }
                        ForEach(systemState.windows) { win in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(win.color)
                                    .frame(width: 140, height: 200)
                                    .overlay(win.icon.view(size: 40, color: .white.opacity(0.85)))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.wosBorder))
                                HStack {
                                    Text(win.title).font(.system(size: 12)).foregroundColor(.white).lineLimit(1)
                                    Spacer()
                                    Button(action: { systemState.closeWindow(win.id) }) {
                                        Image(systemName: "xmark.circle.fill").font(.system(size: 16)).foregroundColor(.wosDanger)
                                    }
                                }
                                .frame(width: 140)
                            }
                            .onTapGesture { systemState.bringToFront(win.id); onClose() }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
        .background(Color.black.opacity(0.6).onTapGesture(perform: onClose))
    }
}
