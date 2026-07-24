// MusicAppView.swift
// Beautiful music player with gradient album art and smooth animations.
import SwiftUI

private struct Song: Identifiable {
    let id: Int
    let title: String
    let artist: String
    let duration: String
    let color: Color
}

struct MusicAppView: View {
    @State private var songs: [Song] = [
        Song(id: 1, title: "Midnight City", artist: "M83", duration: "4:03", color: Color(hex: "6366f1")),
        Song(id: 2, title: "Blinding Lights", artist: "The Weeknd", duration: "3:20", color: Color(hex: "ef4444")),
        Song(id: 3, title: "Levitating", artist: "Dua Lipa", duration: "3:23", color: Color(hex: "ec4899")),
        Song(id: 4, title: "Stay", artist: "The Kid LAROI", duration: "2:21", color: Color(hex: "3b82f6")),
        Song(id: 5, title: "Peaches", artist: "Justin Bieber", duration: "3:18", color: Color(hex: "f97316")),
    ]
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var rotation: Double = 0
    @State private var appears = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var song: Song { songs[currentIndex] }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Album art
                albumArt

                // Song info
                VStack(spacing: 6) {
                    Text(song.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(song.artist)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.wosTextSecondary)
                }

                // Progress bar
                progressSection

                // Controls
                controls

                // Playlist
                playlist
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .background(Color.wosBackground)
        .onAppear {
            withAnimation(.spring(response: 0.6)) { appears = true }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            progress = progress >= 100 ? 0 : progress + 0.3
            rotation += 0.8
        }
    }

    // MARK: - Album Art

    private var albumArt: some View {
        ZStack {
            // Glow
            Circle()
                .fill(song.color.opacity(0.2))
                .frame(width: 200, height: 200)
                .blur(radius: 30)

            // Album circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [song.color, song.color.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 180)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                )
                .rotationEffect(.degrees(isPlaying ? rotation : 0))
                .shadow(color: song.color.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .opacity(appears ? 1 : 0)
        .scaleEffect(appears ? 1 : 0.8)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.wosPanelAlt)
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [song.color, song.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress / 100, height: 4)
                        .shadow(color: song.color.opacity(0.3), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 4)

            HStack {
                Text(formattedTime(progress * 6))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.wosTextMuted)
                Spacer()
                Text(song.duration)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.wosTextMuted)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 36) {
            // Previous
            Button(action: prev) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }

            // Play/Pause
            Button(action: togglePlay) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [song.color, song.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: song.color.opacity(0.4), radius: 12, x: 0, y: 6)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: isPlaying ? 0 : 2)
                }
            }

            // Next
            Button(action: next) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Playlist

    private var playlist: some View {
        VStack(spacing: 0) {
            ForEach(Array(songs.enumerated()), id: \.element.id) { idx, s in
                Button(action: { selectSong(idx) }) {
                    HStack(spacing: 12) {
                        // Album thumbnail
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [s.color, s.color.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(s.title)
                                .font(.system(size: 15, weight: idx == currentIndex ? .semibold : .regular))
                                .foregroundColor(idx == currentIndex ? song.color : .white)
                            Text(s.artist)
                                .font(.system(size: 12))
                                .foregroundColor(Color.wosTextMuted)
                        }

                        Spacer()

                        if idx == currentIndex && isPlaying {
                            playingIndicator
                        }

                        Text(s.duration)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.wosTextDisabled)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(idx == currentIndex ? song.color.opacity(0.08) : Color.clear)
                }
                .buttonStyle(.plain)

                if idx < songs.count - 1 {
                    Divider()
                        .background(Color.wosBorder)
                        .padding(.leading, 72)
                }
            }
        }
    }

    private var playingIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(song.color)
                    .frame(width: 2, height: CGFloat(8 + i * 4))
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1),
                        value: isPlaying
                    )
            }
        }
    }

    // MARK: - Actions

    private func togglePlay() { isPlaying.toggle() }
    private func next() {
        withAnimation(.spring(response: 0.3)) {
            currentIndex = (currentIndex + 1) % songs.count
            progress = 0
        }
    }
    private func prev() {
        withAnimation(.spring(response: 0.3)) {
            currentIndex = (currentIndex - 1 + songs.count) % songs.count
            progress = 0
        }
    }
    private func selectSong(_ idx: Int) {
        withAnimation(.spring(response: 0.3)) {
            currentIndex = idx
            progress = 0
            isPlaying = true
        }
    }

    private func formattedTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    MusicAppView()
}
