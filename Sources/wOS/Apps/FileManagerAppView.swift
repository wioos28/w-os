// FileManagerAppView.swift
// Ported 1:1 from src/screens/FileManagerScreen.js
import SwiftUI

private struct DemoFile: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let size: String
    let system: Bool
}

struct FileManagerAppView: View {
    @State private var files: [DemoFile] = [
        DemoFile(name: "readme.txt", type: "text", size: "1.2 KB", system: true),
        DemoFile(name: "config.json", type: "json", size: "0.8 KB", system: true),
        DemoFile(name: "app.swift", type: "swift", size: "4.5 KB", system: false),
        DemoFile(name: "style.css", type: "css", size: "2.1 KB", system: false),
        DemoFile(name: "data.tsx", type: "tsx", size: "3.2 KB", system: false),
        DemoFile(name: "notes.txt", type: "text", size: "0.5 KB", system: false),
    ]
    @State private var selected: DemoFile?
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tệp").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Spacer()
                HStack(spacing: 4) { Image(systemName: "plus").font(.system(size: 12)); Text("Mới").font(.system(size: 13)) }
                    .foregroundColor(.wosAccent)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)

            HStack {
                Image(systemName: "folder.fill").font(.system(size: 11)).foregroundColor(Color(hex: "666666"))
                Text("/home/user/files").font(.system(size: 12)).foregroundColor(Color(hex: "666666"))
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color(hex: "111111"))

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(files) { file in
                        HStack {
                            Image(systemName: icon(for: file.type)).font(.system(size: 18)).foregroundColor(Color(hex: "8ab4ff")).frame(width: 26)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.name).font(.system(size: 14)).foregroundColor(.white)
                                Text("\(file.size)\(file.system ? " • Hệ thống" : "")").font(.system(size: 11)).foregroundColor(Color(hex: "555555"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(Color(hex: "333333"))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .overlay(Divider().background(Color(hex: "111111")), alignment: .bottom)
                        .onTapGesture { selected = file }
                    }
                }
            }
        }
        .background(Color.wosBackground)
        .alert(selected?.name ?? "", isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
            if let f = selected, !f.system {
                Button("Xóa", role: .destructive) { files.removeAll { $0.id == f.id }; selected = nil }
            }
            Button("Đóng", role: .cancel) { selected = nil }
        } message: {
            if let f = selected {
                Text(f.system ? "File hệ thống - không thể xóa\nKích thước: \(f.size)" : "Kích thước: \(f.size)\nLoại: \(f.type)")
            }
        }
    }

    private func icon(for type: String) -> String {
        switch type {
        case "text": return "doc.text"
        case "json": return "curlybraces"
        case "swift", "js": return "chevron.left.slash.chevron.right"
        case "css": return "paintpalette"
        case "tsx": return "square.stack.3d.up"
        default: return "doc"
        }
    }
}
