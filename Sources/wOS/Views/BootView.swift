// BootView.swift
// Ported 1:1 from src/components/BootScreen.js (fade+scale logo, progress bar, version tag).
import SwiftUI

struct BootView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0a0a0a"), Color(hex: "1a1a2e"), Color(hex: "0a0a0a")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.wosAccent)
                            .frame(width: 80, height: 80)
                        Text("W")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("W OS")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .kerning(4)
                    Text("POWERING YOUR WORLD")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "888888"))
                        .kerning(2)
                }
                .opacity(opacity)
                .scaleEffect(scale)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "222222")).frame(height: 3)
                        Capsule().fill(Color.wosAccent).frame(width: geo.size.width * progress, height: 3)
                    }
                }
                .frame(width: 120, height: 3)
                .padding(.top, 40)
            }

            VStack {
                Spacer()
                Text("v2.1.0")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "444444"))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                opacity = 1
                scale = 1
            }
            withAnimation(.easeInOut(duration: 1.5).delay(0.8)) {
                progress = 1
            }
        }
    }
}
