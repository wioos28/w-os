// AppStoreAppView.swift
// Ported 1:1 from src/screens/AppStoreScreen.js — real-apps catalog with a
// genuine simulated install progress bar, categories, search, a "Hệ thống"
// tab listing built-in apps, and a detail sheet with a real "Mở/Cài đặt" +
// "Xem trang web" actions (LinkingService — not simulated).
import SwiftUI

struct AppStoreAppView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var tab = "real" // "real" | "system"
    @State private var apps: [RealApp] = []
    @State private var source = "offline"
    @State private var loading = true
    @State private var query = ""
    @State private var category = "Tất cả"
    @State private var selected: RealApp?
    @State private var installingId: String?
    @State private var progress: Double = 0

    private var categories: [String] { ["Tất cả"] + RealAppsData.categories }

    private var filtered: [RealApp] {
        apps.filter { app in
            (category == "Tất cả" || app.category == category) &&
            (query.trimmingCharacters(in: .whitespaces).isEmpty || app.name.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            tabs

            if tab == "real" {
                searchAndCategories
                if loading {
                    Spacer()
                    ProgressView().tint(.wosAccent)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            Text("Bấm \"Cài đặt\" để thêm biểu tượng vào máy. Bấm vào app sẽ mở đúng ứng dụng/trang thật — không phải giả lập.")
                                .font(.system(size: 11)).foregroundColor(Color(hex: "666666"))
                                .padding(.horizontal, 4)
                            ForEach(filtered) { app in appCard(app) }
                            if filtered.isEmpty {
                                Text("Không tìm thấy ứng dụng nào").foregroundColor(Color(hex: "555555")).padding(.top, 20)
                            }
                        }
                        .padding(12)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Đây là các app hệ thống có sẵn trong W OS — luôn xuất hiện trên màn hình chính.")
                            .font(.system(size: 11)).foregroundColor(Color(hex: "666666"))
                        ForEach(SystemAppsData.list) { app in
                            HStack {
                                RoundedRectangle(cornerRadius: 12).fill(app.color).frame(width: 48, height: 48)
                                    .overlay(app.icon.view(size: 22, color: .white))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                    Text("Ứng dụng hệ thống").font(.system(size: 11)).foregroundColor(Color(hex: "888888"))
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.wosSuccess)
                            }
                            .padding(10)
                            .background(Color(hex: "111111")).cornerRadius(12)
                        }
                    }
                    .padding(12)
                }
            }
        }
        .background(Color.wosBackground)
        .onAppear(perform: load)
        .sheet(item: $selected) { app in detailSheet(app) }
    }

    private var header: some View {
        HStack {
            Text("Thư viện App").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Spacer()
            sourceBadge
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 6)
    }

    private var sourceBadge: some View {
        let map: [String: (String, Color, String)] = [
            "cloud": ("Đồng bộ Cloud", .wosSuccess, "checkmark.icloud.fill"),
            "cache": ("Dữ liệu đã lưu", .wosWarning, "icloud.slash.fill"),
            "offline": ("Danh mục mặc định", Color(hex: "6b7280"), "icloud.slash"),
        ]
        let (label, color, symbol) = map[source] ?? map["offline"]!
        return HStack(spacing: 4) {
            Image(systemName: symbol).font(.system(size: 10)).foregroundColor(color)
            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(color)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color))
    }

    private var tabs: some View {
        HStack(spacing: 8) {
            tabButton("real", label: "Ứng dụng thật", icon: "globe")
            tabButton("system", label: "Hệ thống", icon: "cpu")
        }
        .padding(.horizontal, 16).padding(.bottom, 6)
    }

    private func tabButton(_ key: String, label: String, icon: String) -> some View {
        Button(action: { tab = key }) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(tab == key ? .white : Color(hex: "888888"))
            .padding(.vertical, 7).padding(.horizontal, 12)
            .background(tab == key ? Color.wosAccent : Color(hex: "1a1a1a"))
            .cornerRadius(10)
        }
    }

    private var searchAndCategories: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundColor(Color(hex: "666666"))
                TextField("", text: $query, prompt: Text("Tìm Google, Spotify, TikTok...").foregroundColor(Color(hex: "555555")))
                    .foregroundColor(.white).autocapitalization(.none)
            }
            .padding(8).background(Color(hex: "1a1a1a")).cornerRadius(10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { c in
                        Text(c).font(.system(size: 12, weight: .medium))
                            .foregroundColor(category == c ? .white : Color(hex: "888888"))
                            .padding(.vertical, 6).padding(.horizontal, 12)
                            .background(category == c ? Color.wosAccent : Color(hex: "1a1a1a"))
                            .cornerRadius(20)
                            .onTapGesture { category = c }
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.bottom, 6)
    }

    private func appCard(_ app: RealApp) -> some View {
        let installed = systemState.isInstalled(app.id)
        let installing = installingId == app.id
        return HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12).fill(app.color).frame(width: 48, height: 48)
                .overlay(app.icon.view(size: 22, color: .white))
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(app.desc).font(.system(size: 11)).foregroundColor(Color(hex: "888888")).lineLimit(1)
            }
            Spacer()
            if installing {
                Text("\(Int(progress))%").font(.system(size: 11, weight: .bold)).foregroundColor(.wosAccent)
            } else {
                Button(action: { startInstall(app) }) {
                    HStack(spacing: 4) {
                        Image(systemName: installed ? "arrow.up.right.square.fill" : "arrow.down.circle.fill").font(.system(size: 11))
                        Text(installed ? "Mở" : "Cài đặt").font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 7).padding(.horizontal, 10)
                    .background(installed ? Color.wosSuccess : Color.wosAccent)
                    .cornerRadius(8)
                }
            }
        }
        .padding(10)
        .background(Color(hex: "111111")).cornerRadius(14)
        .onTapGesture { selected = app }
    }

    private func detailSheet(_ app: RealApp) -> some View {
        VStack(spacing: 16) {
            Capsule().fill(Color(hex: "444444")).frame(width: 36, height: 4).padding(.top, 10)
            RoundedRectangle(cornerRadius: 20).fill(app.color).frame(width: 80, height: 80)
                .overlay(app.icon.view(size: 36, color: .white))
            Text(app.name).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(app.desc).font(.system(size: 13)).foregroundColor(Color(hex: "999999")).multilineTextAlignment(.center)

            HStack {
                Image(systemName: "link").font(.system(size: 11)).foregroundColor(.wosAccent)
                Text(app.url).font(.system(size: 12)).foregroundColor(.wosAccent).lineLimit(1)
            }
            .padding(10).background(Color(hex: "1a1a1a")).cornerRadius(10)

            HStack(spacing: 10) {
                Button(action: { startInstall(app); selected = nil }) {
                    HStack { Image(systemName: systemState.isInstalled(app.id) ? "arrow.up.right.square.fill" : "arrow.down.circle.fill"); Text(systemState.isInstalled(app.id) ? "Mở ứng dụng" : "Cài đặt") }
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(Color.wosAccent).cornerRadius(12)
                }
                if systemState.isInstalled(app.id) {
                    Button(action: { systemState.uninstallApp(app); selected = nil }) {
                        Text("Gỡ").font(.system(size: 14, weight: .bold)).foregroundColor(.wosDanger)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(Color(hex: "1a1a1a")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.wosBorder))
                    }
                }
            }

            Text("Mở qua liên kết thật (URL scheme hoặc https) — không giả lập.")
                .font(.system(size: 10.5)).foregroundColor(Color(hex: "555555")).multilineTextAlignment(.center)
            Spacer()
        }
        .padding(24)
        .background(Color.wosBackground.ignoresSafeArea())
    }

    private func load() {
        loading = true
        CloudSyncService.shared.getRealAppsCatalog { fetchedApps, src in
            apps = fetchedApps
            source = src
            loading = false
        }
    }

    private func startInstall(_ app: RealApp) {
        if systemState.isInstalled(app.id) {
            LinkingService.openRealApp(app)
            return
        }
        installingId = app.id
        progress = 0
        Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { timer in
            progress += Double.random(in: 15...30)
            if progress >= 100 {
                progress = 100
                timer.invalidate()
                systemState.installApp(app)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { installingId = nil; progress = 0 }
            }
        }
    }
}
