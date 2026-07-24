// BootView.swift
// Cinematic boot screen with particle effects, animated logo, and smooth progress.
import SwiftUI

struct BootView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var progress: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.wosBootGradient.ignoresSafeArea()

            // Animated background circles
            backgroundEffects

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Logo with glow
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(Color.wosAccent.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .rotationEffect(.degrees(rotation))

                    // Middle glow
                    Circle()
                        .fill(Color.wosAccent.opacity(glowOpacity * 0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)

                    // Logo container
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color.wosAccent, Color.wosAccentDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.wosAccent.opacity(0.5), radius: 30, x: 0, y: 10)

                        Text("W")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }

                Spacer().frame(height: 32)

                // Title
                Text("W OS")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .kerning(6)
                    .opacity(textOpacity)

                Spacer().frame(height: 8)

                // Tagline
                Text("POWERING YOUR WORLD")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.wosTextMuted)
                    .kerning(3)
                    .opacity(textOpacity)

                Spacer().frame(height: 60)

                // Progress bar
                VStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.wosAccent, Color.wosAccentLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 4)
                                .shadow(color: Color.wosAccent.opacity(0.5), radius: 8, x: 0, y: 0)
                        }
                    }
                    .frame(width: 140, height: 4)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.wosTextMuted)
                }
                .opacity(textOpacity)

                Spacer()

                // Version
                Text("v2.1.0 • Swift Native")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.wosTextDisabled)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startBootAnimation()
        }
    }

    // MARK: - Background Effects

    private var backgroundEffects: some View {
        ZStack {
            // Floating orbs
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.wosAccent.opacity(0.05))
                    .frame(width: CGFloat(200 + i * 100), height: CGFloat(200 + i * 100))
                    .blur(radius: CGFloat(60 + i * 20))
                    .offset(
                        x: CGFloat(i % 2 == 0 ? -50 : 50),
                        y: CGFloat(i * 30)
                    )
            }
        }
        .opacity(particleOpacity)
    }

    // MARK: - Animation

    private func startBootAnimation() {
        // Logo fade in + scale
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Glow effect
        withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
            glowOpacity = 1
        }

        // Ring animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
            ringOpacity = 1
            ringScale = 1
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.5)) {
            rotation = 360
        }

        // Text fade in
        withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
            textOpacity = 1
        }

        // Background particles
        withAnimation(.easeInOut(duration: 1.5).delay(0.2)) {
            particleOpacity = 1
        }

        // Progress bar
        withAnimation(.easeInOut(duration: 2.0).delay(0.8)) {
            progress = 1
        }
    }
}

#Preview {
    BootView()
}
