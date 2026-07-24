// NotesAppView.swift
// Ported 1:1 from src/screens/NotesScreen.js — local persistence + optional
// cloud sync via CloudSyncService (mirrors fetchRemoteNotes/pushNote/deleteRemoteNote).
import SwiftUI

private struct LocalNote: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var cloudId: String?
}

struct NotesAppView: View {
    @State private var notes: [LocalNote] = []
    @State private var editingIndex: Int?
    @State private var title = ""
    @State private var content = ""
    @State private var syncing = false
    @State private var isEditing = false

    private let storageKey = "wos_notes"

    var body: some View {
        Group {
            if isEditing {
                editor
            } else {
                list
            }
        }
        .background(Color.wosBackground)
        .onAppear(perform: loadNotes)
    }

    private var list: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Text("Ghi chú").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    if syncing { ProgressView().tint(.wosAccent).scaleEffect(0.7) }
                }
                Spacer()
                Button(action: createNote) {
                    HStack(spacing: 4) { Image(systemName: "plus"); Text("Mới") }
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.vertical, 6).padding(.horizontal, 12)
                        .background(Color.wosAccent).cornerRadius(8)
                }
            }
            .padding(16)
            .overlay(Divider().background(Color(hex: "1a1a1a")), alignment: .bottom)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(notes.enumerated()), id: \.element.id) { idx, note in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(note.title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                                if note.cloudId != nil { Image(systemName: "checkmark.icloud.fill").font(.system(size: 11)).foregroundColor(.wosSuccess) }
                            }
                            Text(note.content).font(.system(size: 13)).foregroundColor(Color(hex: "888888")).lineLimit(2)
                            Text(formatted(note.date)).font(.system(size: 11)).foregroundColor(Color(hex: "555555"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(hex: "111111")).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "1a1a1a")))
                        .onTapGesture { openNote(idx) }
                        .onLongPressGesture { deleteNote(idx) }
                    }
                    if notes.isEmpty {
                        Text("Chưa có ghi chú nào").foregroundColor(Color(hex: "444444")).padding(.top, 40)
                    }
                }
                .padding(12)
            }
        }
    }

    private var editor: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { isEditing = false; editingIndex = nil; title = ""; content = "" }) {
                    HStack(spacing: 3) { Image(systemName: "chevron.left"); Text("Danh sách") }
                        .font(.system(size: 14)).foregroundColor(.wosAccent)
                }
                Spacer()
                Button("Lưu", action: saveCurrent).font(.system(size: 14, weight: .semibold)).foregroundColor(.wosAccent)
            }
            .padding(16)
            TextField("", text: $title, prompt: Text("Tiêu đề...").foregroundColor(Color(hex: "555555")))
                .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                .padding(16)
                .overlay(Divider().background(Color(hex: "1a1a1a")), alignment: .bottom)
            TextEditor(text: $content)
                .font(.system(size: 15)).foregroundColor(.white).scrollContentBackground(.hidden)
                .padding(12)
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: storageKey), let decoded = try? JSONDecoder().decode([LocalNote].self, from: data) {
            notes = decoded
        }
        syncing = true
        CloudSyncService.shared.fetchRemoteNotes { remote in
            syncing = false
            guard let remote else { return }
            let localCloudIds = Set(notes.compactMap { $0.cloudId })
            let incoming = remote.filter { !localCloudIds.contains($0.id) }
                .map { LocalNote(title: $0.title, content: $0.content, date: Date(), cloudId: $0.id) }
            if !incoming.isEmpty { notes = incoming + notes; persist() }
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(notes) { UserDefaults.standard.set(data, forKey: storageKey) }
    }

    private func createNote() {
        editingIndex = nil
        title = ""; content = ""
        isEditing = true
    }

    private func openNote(_ idx: Int) {
        editingIndex = idx
        title = notes[idx].title
        content = notes[idx].content
        isEditing = true
    }

    private func saveCurrent() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty || !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            isEditing = false; return
        }
        let existingCloudId = editingIndex.flatMap { notes[$0].cloudId }
        CloudSyncService.shared.pushNote(RemoteNote(id: existingCloudId ?? UUID().uuidString, title: title, content: content)) { _ in }

        if let idx = editingIndex {
            notes[idx].title = title.isEmpty ? "Không tiêu đề" : title
            notes[idx].content = content
            notes[idx].date = Date()
        } else {
            notes.insert(LocalNote(title: title.isEmpty ? "Không tiêu đề" : title, content: content, date: Date(), cloudId: existingCloudId), at: 0)
        }
        persist()
        isEditing = false
        editingIndex = nil
        title = ""; content = ""
    }

    private func deleteNote(_ idx: Int) {
        let note = notes[idx]
        if let cloudId = note.cloudId { CloudSyncService.shared.deleteRemoteNote(cloudId) { _ in } }
        notes.remove(at: idx)
        persist()
    }

    private func formatted(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "d MMM, HH:mm"
        return f.string(from: d)
    }
}
