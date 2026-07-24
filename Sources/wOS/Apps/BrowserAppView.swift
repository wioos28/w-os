// BrowserAppView.swift
// Ported 1:1 from src/screens/BrowserScreen.js using a real WKWebView
// (the native iOS equivalent of react-native-webview).
import SwiftUI
import WebKit

struct BrowserAppView: View {
    @State private var inputUrl = "https://www.google.com"
    @State private var currentUrl = URL(string: "https://www.google.com")!
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var webView = WKWebView()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("", text: $inputUrl, prompt: Text("Nhập URL...").foregroundColor(Color(hex: "555555")))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.wosBackground)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.wosBorder))
                    .onSubmit(go)
                Button(action: go) {
                    Image(systemName: "arrow.forward.circle.fill").font(.system(size: 22)).foregroundColor(.wosAccent)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(hex: "111111"))

            HStack(spacing: 30) {
                Button(action: { webView.goBack() }) {
                    Image(systemName: "chevron.left").foregroundColor(canGoBack ? Color(hex: "cccccc") : Color(hex: "cccccc").opacity(0.3))
                }.disabled(!canGoBack)
                Button(action: { webView.goForward() }) {
                    Image(systemName: "chevron.right").foregroundColor(canGoForward ? Color(hex: "cccccc") : Color(hex: "cccccc").opacity(0.3))
                }.disabled(!canGoForward)
                Button(action: { webView.reload() }) { Image(systemName: "arrow.clockwise").foregroundColor(Color(hex: "cccccc")) }
                Button(action: { navigate(to: "https://www.google.com") }) { Image(systemName: "house").foregroundColor(Color(hex: "cccccc")) }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(hex: "111111"))

            WebViewRepresentable(webView: webView, url: currentUrl, canGoBack: $canGoBack, canGoForward: $canGoForward, inputUrl: $inputUrl)
        }
        .background(Color.wosBackground)
    }

    private func go() {
        var s = inputUrl.trimmingCharacters(in: .whitespaces)
        if !s.lowercased().hasPrefix("http") { s = "https://" + s }
        navigate(to: s)
    }

    private func navigate(to s: String) {
        guard let url = URL(string: s) else { return }
        currentUrl = url
        inputUrl = s
        webView.load(URLRequest(url: url))
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let url: URL
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var inputUrl: String

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
        init(_ parent: WebViewRepresentable) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            if let url = webView.url { parent.inputUrl = url.absoluteString }
        }
    }
}
