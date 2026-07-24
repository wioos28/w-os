// BrowserAppView.swift
// Modern browser with tabs, bookmarks, history, and progress indicator.
import SwiftUI
import WOSCore
import WebKit

struct BrowserAppView: View {
    @State private var tabs: [BrowserTab] = [BrowserTab(url: "https://www.google.com")]
    @State private var selectedTabIndex = 0
    @State private var inputUrl = "https://www.google.com"
    @State private var isLoading = false
    @State private var loadingProgress: Double = 0
    @State private var bookmarks: [String] = UserDefaults.standard.stringArray(forKey: "wos_browser_bookmarks") ?? []
    @State private var showBookmarks = false
    @State private var isPrivateMode = false

    private var currentTab: Binding<BrowserTab> {
        $tabs[selectedTabIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            tabBar

            // URL bar
            urlBar

            // Loading progress
            if isLoading {
                ProgressView(value: loadingProgress)
                    .tint(.wosAccent)
                    .frame(height: 2)
            }

            // WebView
            BrowserWebView(
                url: currentTab.wrappedValue.url,
                isLoading: $isLoading,
                loadingProgress: $loadingProgress,
                onURLChange: { url in
                    inputUrl = url
                    tabs[selectedTabIndex].url = url
                }
            )
        }
        .background(Color.wosBackground)
        .sheet(isPresented: $showBookmarks) {
            bookmarksList
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                Button(action: { selectedTabIndex = index }) {
                    HStack(spacing: 4) {
                        Image(systemName: isPrivateMode ? "moon.fill" : "globe")
                            .font(.system(size: 10))
                        Text(tabTitle(tab))
                            .font(.system(size: 11))
                            .lineLimit(1)
                        if tabs.count > 1 {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .onTapGesture { closeTab(at: index) }
                        }
                    }
                    .foregroundColor(selectedTabIndex == index ? .white : Color(hex: "888888"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedTabIndex == index ? Color(hex: "1a1a1a") : Color.clear)
                }
            }

            Button(action: addTab) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
            }
        }
        .background(Color(hex: "111111"))
    }

    // MARK: - URL Bar

    @ViewBuilder
    private var urlBar: some View {
        HStack(spacing: 8) {
            Button(action: { showBookmarks = true }) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isPrivateMode ? .wosWarning : .wosAccent)
            }

            HStack(spacing: 6) {
                Image(systemName: isPrivateMode ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "666666"))

                TextField("", text: $inputUrl, prompt: Text("Tìm kiếm hoặc nhập URL").foregroundColor(Color(hex: "555555")))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit(go)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(hex: "1a1a1a"))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.wosBorder))

            Button(action: go) {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.wosAccent)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "111111"))

        HStack(spacing: 24) {
            Button(action: { tabs[selectedTabIndex].canGoBack = true }) {
                Image(systemName: "chevron.left").foregroundColor(Color(hex: "cccccc"))
            }
            Button(action: { tabs[selectedTabIndex].canGoForward = true }) {
                Image(systemName: "chevron.right").foregroundColor(Color(hex: "cccccc"))
            }
            Button(action: reload) {
                Image(systemName: "arrow.clockwise").foregroundColor(Color(hex: "cccccc"))
            }
            Button(action: goHome) {
                Image(systemName: "house").foregroundColor(Color(hex: "cccccc"))
            }
            Spacer()
            Button(action: togglePrivate) {
                Image(systemName: isPrivateMode ? "moon.fill" : "moon")
                    .foregroundColor(isPrivateMode ? .wosWarning : Color(hex: "cccccc"))
            }
            Button(action: share) {
                Image(systemName: "square.and.arrow.up").foregroundColor(Color(hex: "cccccc"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: "111111"))
    }

    // MARK: - Bookmarks Sheet

    private var bookmarksList: some View {
        NavigationView {
            List {
                Section("Đã lưu") {
                    ForEach(bookmarks, id: \.self) { url in
                        Button(action: {
                            inputUrl = url
                            go()
                            showBookmarks = false
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.wosAccent)
                                Text(url)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        bookmarks.remove(atOffsets: indexSet)
                        UserDefaults.standard.set(bookmarks, forKey: "wos_browser_bookmarks")
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { showBookmarks = false }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Thêm") {
                        if !inputUrl.isEmpty && !bookmarks.contains(inputUrl) {
                            bookmarks.append(inputUrl)
                            UserDefaults.standard.set(bookmarks, forKey: "wos_browser_bookmarks")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func tabTitle(_ tab: BrowserTab) -> String {
        URL(string: tab.url)?.host ?? "New Tab"
    }

    private func addTab() {
        tabs.append(BrowserTab(url: "https://www.google.com"))
        selectedTabIndex = tabs.count - 1
    }

    private func closeTab(at index: Int) {
        tabs.remove(at: index)
        if selectedTabIndex >= tabs.count { selectedTabIndex = max(0, tabs.count - 1) }
    }

    private func go() {
        var s = inputUrl.trimmingCharacters(in: .whitespaces)
        if !s.lowercased().hasPrefix("http") { s = "https://" + s }
        tabs[selectedTabIndex].url = s
    }

    private func reload() {
        tabs[selectedTabIndex].url = tabs[selectedTabIndex].url
    }

    private func goHome() {
        inputUrl = "https://www.google.com"
        tabs[selectedTabIndex].url = "https://www.google.com"
    }

    private func togglePrivate() { isPrivateMode.toggle() }

    private func share() {
        guard let url = URL(string: tabs[selectedTabIndex].url) else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(av, animated: true)
    }
}

// MARK: - Models

struct BrowserTab: Identifiable {
    let id = UUID()
    var url: String
    var canGoBack = false
    var canGoForward = false
}

// MARK: - WebView Representable

struct BrowserWebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    var onURLChange: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let currentURL = uiView.url?.absoluteString, currentURL != url {
            if let newURL = URL(string: url) {
                uiView.load(URLRequest(url: newURL))
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BrowserWebView
        init(_ parent: BrowserWebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.loadingProgress = 0.3
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 1.0
                if let url = webView.url {
                    self.parent.onURLChange(url.absoluteString)
                }
            }
        }

        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - UIApplication Extension

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
