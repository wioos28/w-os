// MultitaskView.swift
// Modern app switcher with glassmorphism cards and smooth animations.
import SwiftUI
import WOSCore

struct MultitaskView: View {
    var onClose: () -> Void
    @EnvironmentObject var systemState: WOSShellState
    @State private var appears = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Đa nhiệm")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    if !systemState.windows.isEmpty {
                        Button(action: closeAll) {
                            Text("Đóng tất cả")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.wosDanger)
                        }
                    }
                }

                if systemState.windows.isEmpty {
                    emptyState
                } else {
                    appCards
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.95)
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 80)
            .offset(y: appears ? 0 : 40)
            .opacity(appears ? 1 : 0)
        }
        .background(Color.black.opacity(0.5).onTapGesture(perform: onClose))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appears = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(Color.wosTextDisabled)
            Text("Không có app nào đang chạy")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.wosTextMuted)
            Text("Mở app từ màn hình chính")
                .font(.system(size: 12))
                .foregroundColor(Color.wosTextDisabled)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - App Cards

    private var appCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Array(systemState.windows.enumerated()), id: \.element.id) { index, win in
                    appCard(win, index: index)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func appCard(_ win: WindowInstance, index: Int) -> some View {
        VStack(spacing: 0) {
            // App preview
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [win.color, win.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                win.icon.view(size: 48, color: .white.opacity(0.9))
            }
            .frame(width: 130, height: 180)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )

            // App info bar
            HStack(spacing: 6) {
                Circle()
                    .fill(win.color)
                    .frame(width: 6, height: 6)

                Text(win.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        systemState.closeWindow(win.id)
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.wosTextSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(width: 130)
        .shadow(color: win.color.opacity(0.2), radius: 12, x: 0, y: 6)
        .onTapGesture {
            systemState.bringToFront(win.id)
            onClose()
        }
        .offset(y: appears ? 0 : 30)
        .opacity(appears ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + Double(index) * 0.06), value: appears)
    }

    // MARK: - Actions

    private func closeAll() {
        withAnimation(.spring(response: 0.4)) {
            for win in systemState.windows {
                systemState.closeWindow(win.id)
            }
        }
    }
}

#Preview {
    MultitaskView(onClose: {})
        .environmentObject(WOSShellState())
}
