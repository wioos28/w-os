// WebViewAppView.swift
// In-app web browser for installed real apps - keeps users within W OS.
import SwiftUI
import WebKit

struct WebViewAppView: View {
    let app: RealApp
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    @State private var canGoBack = false
    @State private var canGoForward = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with app info
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(app.color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: app.iconSymbol)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(app.desc)
                        .font(.system(size: 11))
                        .foregroundColor(Color.wosTextMuted)
                        .lineLimit(1)
                }

                Spacer()

                // Open in Safari button
                Button(action: { LinkingService.openInSafari(app.url) }) {
                    Image(systemName: "safari")
                        .font(.system(size: 16))
                        .foregroundColor(.wosAccent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.wosPanel)

            // Progress bar
            if isLoading {
                ProgressView(value: loadingProgress)
                    .tint(.wosAccent)
                    .frame(height: 2)
            }

            // Navigation bar
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(canGoBack ? .white : Color.wosTextDisabled)
                }
                .disabled(!canGoBack)

                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canGoForward ? .white : Color.wosTextDisabled)
                }
                .disabled(!canGoForward)

                Spacer()

                Text(URL(string: app.url)?.host ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(Color.wosTextMuted)
                    .lineLimit(1)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.wosPanelAlt)

            // WebView
            InAppWebView(url: app.url, isLoading: $isLoading, loadingProgress: $loadingProgress)
        }
        .background(Color.wosBackground)
    }
}

// MARK: - In-App WebView

struct InAppWebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double

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

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: InAppWebView
        init(_ parent: InAppWebView) { self.parent = parent }

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
            }
        }
    }
}

#Preview {
    WebViewAppView(app: RealAppsData.all[0])
}
