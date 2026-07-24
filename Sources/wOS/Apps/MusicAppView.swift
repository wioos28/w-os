// MusicAppView.swift
// Ported 1:1 from src/screens/MusicScreen.js — playlist + rotating album art.
import SwiftUI

private struct Song: Identifiable { let id: Int; let title: String; let artist: String; let duration: String }

struct MusicAppView: View {
    private let songs: [Song] = [
        Song(id: 1, title: "Midnight City", artist: "M83", duration: "4:03"),
        Song(id: 2, title: "Blinding Lights", artist: "The Weeknd", duration: "3:20"),
        Song(id: 3, title: "Levitating", artist: "Dua Lipa", duration: "3:23"),
        Song(id: 4, title: "Stay", artist: "The Kid LAROI", duration: "2:21"),
        Song(id: 5, title: "Peaches", artist: "Justin Bieber", duration: "3:18"),
    ]
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var rotation: Double = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var song: Song { songs[currentIndex] }

    var body: some View {
        VStack(spacing: 18) {
            Circle()
                .fill(Color(hex: "1a1a1a"))
                .frame(width: 180, height: 180)
                .overlay(Circle().stroke(Color(hex: "2a2a2a"), lineWidth: 3))
                .overlay(Image(systemName: "music.note").font(.system(size: 54)).foregroundColor(Color(hex: "8ab4ff")))
                .rotationEffect(.degrees(rotation))
                .padding(.top, 20)

            VStack(spacing: 4) {
                Text(song.title).font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                Text(song.artist).font(.system(size: 14)).foregroundColor(Color(hex: "888888"))
            }

            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "222222")).frame(height: 4)
                        Capsule().fill(Color.wosAccent).frame(width: geo.size.width * progress / 100, height: 4)
                    }
                }
                .frame(height: 4)
                HStack { Text("0:00").font(.system(size: 11)).foregroundColor(Color(hex: "666666")); Spacer(); Text(song.duration).font(.system(size: 11)).foregroundColor(Color(hex: "666666")) }
            }
            .padding(.horizontal, 24)

            HStack(spacing: 30) {
                Button(action: prev) { Image(systemName: "backward.end.fill").font(.system(size: 22)).foregroundColor(.white) }
                Button(action: togglePlay) {
                    Circle().fill(Color.wosAccent).frame(width: 56, height: 56)
                        .overlay(Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 20)).foregroundColor(.white))
                }
                Button(action: next) { Image(systemName: "forward.end.fill").font(.system(size: 22)).foregroundColor(.white) }
            }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(songs.enumerated()), id: \.element.id) { idx, s in
                        HStack {
                            Text("\(idx + 1)").font(.system(size: 13)).foregroundColor(Color(hex: "666666")).frame(width: 24)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(s.title).font(.system(size: 14)).foregroundColor(idx == currentIndex ? .wosAccent : .white)
                                Text(s.artist).font(.system(size: 12)).foregroundColor(Color(hex: "666666"))
                            }
                            Spacer()
                            Text(s.duration).font(.system(size: 12)).foregroundColor(Color(hex: "666666"))
                        }
                        .padding(.vertical, 8)
                        .background(idx == currentIndex ? Color.wosAccent.opacity(0.1) : .clear)
                        .overlay(Divider().background(Color(hex: "111111")), alignment: .bottom)
                        .onTapGesture { currentIndex = idx; progress = 0 }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.wosBackground)
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            progress = progress >= 100 ? 0 : progress + 0.5
            rotation += 1.2
        }
    }

    private func togglePlay() { isPlaying.toggle() }
    private func next() { currentIndex = (currentIndex + 1) % songs.count; progress = 0 }
    private func prev() { currentIndex = (currentIndex - 1 + songs.count) % songs.count; progress = 0 }
}
