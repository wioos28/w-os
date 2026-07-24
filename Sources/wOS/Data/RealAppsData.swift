// RealAppsData.swift
// Ported 1:1 from src/data/realApps.js (REAL_APPS / REAL_APP_CATEGORIES).
// Default/offline catalog of real third-party apps used by the App Store
// screen when the cloud catalog (CloudSyncService) is unreachable.
enum RealAppsData {
    static let categories: [String] = ["Google", "Xã hội", "Nhắn tin", "Giải trí", "Khác"]

    static let all: [RealApp] = [
        RealApp(id: "google",     name: "Google",        category: "Google",  colorHex: "4285F4", iconSymbol: "magnifyingglass.circle.fill", url: "https://www.google.com",          scheme: nil,                    desc: "Tìm kiếm trên Google"),
        RealApp(id: "gmail",      name: "Gmail",          category: "Google",  colorHex: "EA4335", iconSymbol: "envelope.fill",                url: "https://mail.google.com/mail/",   scheme: "googlegmail://",       desc: "Email của Google"),
        RealApp(id: "gmaps",      name: "Google Maps",    category: "Google",  colorHex: "1A73E8", iconSymbol: "map.fill",                     url: "https://maps.google.com",         scheme: "comgooglemaps://",     desc: "Bản đồ & chỉ đường"),
        RealApp(id: "gdrive",     name: "Google Drive",   category: "Google",  colorHex: "0F9D58", iconSymbol: "cloud.fill",                   url: "https://drive.google.com",        scheme: "googledrive://",       desc: "Lưu trữ đám mây"),
        RealApp(id: "youtube",    name: "YouTube",        category: "Giải trí", colorHex: "FF0000", iconSymbol: "play.rectangle.fill",         url: "https://www.youtube.com",         scheme: "youtube://",           desc: "Xem video"),
        RealApp(id: "spotify",    name: "Spotify",        category: "Giải trí", colorHex: "1DB954", iconSymbol: "music.note",                  url: "https://open.spotify.com",        scheme: "spotify://",           desc: "Nghe nhạc trực tuyến"),
        RealApp(id: "netflix",    name: "Netflix",        category: "Giải trí", colorHex: "E50914", iconSymbol: "film.fill",                   url: "https://www.netflix.com",         scheme: "nflx://",              desc: "Xem phim & series"),
        RealApp(id: "facebook",   name: "Facebook",       category: "Xã hội",  colorHex: "1877F2", iconSymbol: "f.circle.fill",                url: "https://www.facebook.com",        scheme: "fb://",                desc: "Mạng xã hội Facebook"),
        RealApp(id: "messenger",  name: "Messenger",      category: "Nhắn tin", colorHex: "00B2FF", iconSymbol: "message.fill",                url: "https://www.messenger.com",       scheme: "fb-messenger://",      desc: "Nhắn tin Messenger"),
        RealApp(id: "instagram",  name: "Instagram",      category: "Xã hội",  colorHex: "C13584", iconSymbol: "camera.fill",                  url: "https://www.instagram.com",       scheme: "instagram://app",      desc: "Chia sẻ ảnh & video"),
        RealApp(id: "tiktok",     name: "TikTok",         category: "Xã hội",  colorHex: "000000", iconSymbol: "music.note.list",              url: "https://www.tiktok.com",          scheme: "tiktok://",            desc: "Video ngắn TikTok"),
        RealApp(id: "whatsapp",   name: "WhatsApp",       category: "Nhắn tin", colorHex: "25D366", iconSymbol: "phone.fill",                  url: "https://web.whatsapp.com",        scheme: "whatsapp://",          desc: "Nhắn tin WhatsApp"),
        RealApp(id: "telegram",   name: "Telegram",       category: "Nhắn tin", colorHex: "26A5E4", iconSymbol: "paperplane.fill",             url: "https://web.telegram.org",        scheme: "tg://",                desc: "Nhắn tin Telegram"),
        RealApp(id: "zalo",       name: "Zalo",           category: "Nhắn tin", colorHex: "0068FF", iconSymbol: "bubble.left.and.bubble.right.fill", url: "https://zalo.me",             scheme: "zalo://",              desc: "Nhắn tin Zalo"),
        RealApp(id: "twitter",    name: "X (Twitter)",    category: "Xã hội",  colorHex: "000000", iconSymbol: "at.circle.fill",               url: "https://x.com",                   scheme: "twitter://",           desc: "Mạng xã hội X"),
        RealApp(id: "discord",    name: "Discord",        category: "Nhắn tin", colorHex: "5865F2", iconSymbol: "gamecontroller.fill",         url: "https://discord.com/app",         scheme: "discord://",           desc: "Chat cộng đồng Discord"),
        RealApp(id: "linkedin",   name: "LinkedIn",       category: "Xã hội",  colorHex: "0A66C2", iconSymbol: "briefcase.fill",               url: "https://www.linkedin.com",        scheme: "linkedin://",          desc: "Mạng xã hội việc làm"),
        RealApp(id: "reddit",     name: "Reddit",         category: "Xã hội",  colorHex: "FF4500", iconSymbol: "flame.fill",                   url: "https://www.reddit.com",          scheme: "reddit://",            desc: "Diễn đàn Reddit"),
        RealApp(id: "github",     name: "GitHub",         category: "Khác",    colorHex: "181717", iconSymbol: "chevron.left.forwardslash.chevron.right", url: "https://github.com", scheme: nil,                    desc: "Lưu trữ mã nguồn"),
        RealApp(id: "amazon",     name: "Amazon",         category: "Khác",    colorHex: "FF9900", iconSymbol: "cart.fill",                    url: "https://www.amazon.com",          scheme: nil,                    desc: "Mua sắm trực tuyến"),
    ]
}
