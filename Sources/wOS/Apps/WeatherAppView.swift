// WeatherAppView.swift
// Ported 1:1 from src/screens/WeatherScreen.js (mock current/hourly/daily data).
import SwiftUI

private struct HourWeather: Identifiable { let id = UUID(); let time: String; let temp: Int; let symbol: String }
private struct DayWeather: Identifiable { let id = UUID(); let day: String; let high: Int; let low: Int; let symbol: String; let condition: String }

struct WeatherAppView: View {
    private let current = (temp: 32, condition: "Nắng", symbol: "sun.max.fill", humidity: 65, wind: "12 km/h", uv: "Cao")
    private let hourly: [HourWeather] = [
        HourWeather(time: "Bây giờ", temp: 32, symbol: "sun.max.fill"), HourWeather(time: "14:00", temp: 33, symbol: "sun.max.fill"),
        HourWeather(time: "15:00", temp: 31, symbol: "cloud.sun.fill"), HourWeather(time: "16:00", temp: 29, symbol: "cloud.sun.fill"),
        HourWeather(time: "17:00", temp: 28, symbol: "cloud.fill"), HourWeather(time: "18:00", temp: 27, symbol: "cloud.fill"),
        HourWeather(time: "19:00", temp: 26, symbol: "moon.fill"),
    ]
    private let daily: [DayWeather] = [
        DayWeather(day: "Hôm nay", high: 33, low: 25, symbol: "sun.max.fill", condition: "Nắng"),
        DayWeather(day: "Thứ 3", high: 31, low: 24, symbol: "cloud.sun.fill", condition: "Mây rải rác"),
        DayWeather(day: "Thứ 4", high: 29, low: 23, symbol: "cloud.rain.fill", condition: "Mưa nhẹ"),
        DayWeather(day: "Thứ 5", high: 30, low: 24, symbol: "cloud.bolt.rain.fill", condition: "Dông"),
        DayWeather(day: "Thứ 6", high: 32, low: 25, symbol: "sun.max.fill", condition: "Nắng"),
        DayWeather(day: "Thứ 7", high: 33, low: 26, symbol: "sun.max.fill", condition: "Nắng"),
        DayWeather(day: "CN", high: 32, low: 25, symbol: "cloud.sun.fill", condition: "Mây rải rác"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Hà Nội, VN").font(.system(size: 16)).foregroundColor(Color(hex: "888888"))
                    Image(systemName: current.symbol).font(.system(size: 54)).foregroundColor(Color(hex: "fbbf24")).padding(.vertical, 6)
                    Text("\(current.temp)°").font(.system(size: 72, weight: .thin)).foregroundColor(.white)
                    Text(current.condition).font(.system(size: 18)).foregroundColor(Color(hex: "aaaaaa"))
                    HStack(spacing: 30) {
                        weatherDetail("Độ ẩm", "\(current.humidity)%")
                        weatherDetail("Gió", current.wind)
                        weatherDetail("UV", current.uv)
                    }
                    .padding(.top, 10)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Theo giờ")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(hourly) { h in
                                VStack(spacing: 6) {
                                    Text(h.time).font(.system(size: 12)).foregroundColor(Color(hex: "888888"))
                                    Image(systemName: h.symbol).font(.system(size: 20)).foregroundColor(Color(hex: "8ab4ff"))
                                    Text("\(h.temp)°").font(.system(size: 14)).foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel("7 ngày tới")
                    ForEach(daily) { d in
                        HStack {
                            Text(d.day).font(.system(size: 14)).foregroundColor(.white).frame(width: 64, alignment: .leading)
                            Image(systemName: d.symbol).font(.system(size: 16)).foregroundColor(Color(hex: "8ab4ff")).frame(width: 26)
                            Text(d.condition).font(.system(size: 12)).foregroundColor(Color(hex: "888888")).frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(d.low)°").font(.system(size: 13)).foregroundColor(Color(hex: "888888"))
                            Text("\(d.high)°").font(.system(size: 13)).foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .overlay(Divider().background(Color(hex: "111111")), alignment: .bottom)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
        .background(Color.wosBackground)
    }

    private func weatherDetail(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 12)).foregroundColor(Color(hex: "666666"))
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased()).font(.system(size: 12, weight: .semibold)).foregroundColor(Color(hex: "888888")).padding(.horizontal, 16)
    }
}
