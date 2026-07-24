// WeatherAppView.swift
// Beautiful weather app with gradient cards and animated elements.
import SwiftUI
import WOSCore

private struct HourWeather: Identifiable {
    let id = UUID()
    let time: String
    let temp: Int
    let symbol: String
    let isNow: Bool
}

private struct DayWeather: Identifiable {
    let id = UUID()
    let day: String
    let high: Int
    let low: Int
    let symbol: String
    let condition: String
    let isToday: Bool
}

struct WeatherAppView: View {
    @State private var appears = false

    private let current = (temp: 32, condition: "Nắng", symbol: "sun.max.fill", humidity: 65, wind: "12 km/h", uv: "Cao")
    private let hourly: [HourWeather] = [
        HourWeather(time: "Bây giờ", temp: 32, symbol: "sun.max.fill", isNow: true),
        HourWeather(time: "14:00", temp: 33, symbol: "sun.max.fill", isNow: false),
        HourWeather(time: "15:00", temp: 31, symbol: "cloud.sun.fill", isNow: false),
        HourWeather(time: "16:00", temp: 29, symbol: "cloud.sun.fill", isNow: false),
        HourWeather(time: "17:00", temp: 28, symbol: "cloud.fill", isNow: false),
        HourWeather(time: "18:00", temp: 27, symbol: "cloud.fill", isNow: false),
        HourWeather(time: "19:00", temp: 26, symbol: "moon.fill", isNow: false),
    ]
    private let daily: [DayWeather] = [
        DayWeather(day: "Hôm nay", high: 33, low: 25, symbol: "sun.max.fill", condition: "Nắng", isToday: true),
        DayWeather(day: "Thứ 3", high: 31, low: 24, symbol: "cloud.sun.fill", condition: "Mây rải rác", isToday: false),
        DayWeather(day: "Thứ 4", high: 29, low: 23, symbol: "cloud.rain.fill", condition: "Mưa nhẹ", isToday: false),
        DayWeather(day: "Thứ 5", high: 30, low: 24, symbol: "cloud.bolt.rain.fill", condition: "Dông", isToday: false),
        DayWeather(day: "Thứ 6", high: 32, low: 25, symbol: "sun.max.fill", condition: "Nắng", isToday: false),
        DayWeather(day: "Thứ 7", high: 33, low: 26, symbol: "sun.max.fill", condition: "Nắng", isToday: false),
        DayWeather(day: "CN", high: 32, low: 25, symbol: "cloud.sun.fill", condition: "Mây rải rác", isToday: false),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Current weather hero
                currentWeatherCard

                // Hourly forecast
                hourlySection

                // Daily forecast
                dailySection

                // Details
                detailsSection
            }
            .padding(.bottom, 20)
        }
        .background(Color.wosBackground)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appears = true
            }
        }
    }

    // MARK: - Current Weather Card

    private var currentWeatherCard: some View {
        VStack(spacing: 12) {
            // Location
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                Text("Hà Nội, VN")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color.wosTextSecondary)

            // Weather icon
            Image(systemName: current.symbol)
                .font(.system(size: 64, weight: .medium))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.3), radius: 20, x: 0, y: 10)

            // Temperature
            Text("\(current.temp)°")
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundColor(.white)

            // Condition
            Text(current.condition)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.wosTextSecondary)

            // Stats row
            HStack(spacing: 24) {
                weatherStat(icon: "humidity.fill", label: "Độ ẩm", value: "\(current.humidity)%")
                weatherStat(icon: "wind", label: "Gió", value: current.wind)
                weatherStat(icon: "sun.max.fill", label: "UV", value: current.uv)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "1e3a5f"), Color(hex: "0a1628")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(24)
        .padding(.horizontal, 16)
        .opacity(appears ? 1 : 0)
        .offset(y: appears ? 0 : 20)
    }

    private func weatherStat(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.wosAccentLight)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.wosTextMuted)
        }
    }

    // MARK: - Hourly Section

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Theo giờ")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hourly) { h in
                        hourlyCard(h)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func hourlyCard(_ h: HourWeather) -> some View {
        VStack(spacing: 8) {
            Text(h.time)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(h.isNow ? .wosAccent : Color.wosTextMuted)

            Image(systemName: h.symbol)
                .font(.system(size: 22))
                .foregroundColor(.wosAccentLight)

            Text("\(h.temp)°")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: 64)
        .padding(.vertical, 12)
        .background(h.isNow ? Color.wosAccent.opacity(0.15) : Color.wosPanelAlt)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(h.isNow ? Color.wosAccent.opacity(0.3) : Color.wosBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Daily Section

    private var dailySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("7 ngày tới")

            VStack(spacing: 0) {
                ForEach(daily) { d in
                    dayRow(d)
                    if d.id != daily.last?.id {
                        Divider()
                            .background(Color.wosBorder)
                            .padding(.leading, 44)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func dayRow(_ d: DayWeather) -> some View {
        HStack(spacing: 12) {
            // Day name
            Text(d.day)
                .font(.system(size: 14, weight: d.isToday ? .semibold : .regular))
                .foregroundColor(d.isToday ? .wosAccent : .white)
                .frame(width: 60, alignment: .leading)

            // Icon
            Image(systemName: d.symbol)
                .font(.system(size: 18))
                .foregroundColor(.wosAccentLight)
                .frame(width: 28)

            // Condition
            Text(d.condition)
                .font(.system(size: 13))
                .foregroundColor(Color.wosTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Temperature range
            HStack(spacing: 8) {
                Text("\(d.low)°")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.wosTextMuted)
                Text("\(d.high)°")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(d.isToday ? Color.wosAccent.opacity(0.05) : Color.clear)
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Chi tiết")

            HStack(spacing: 12) {
                detailCard(icon: "humidity.fill", title: "Độ ẩm", value: "\(current.humidity)%", color: .wosInfo)
                detailCard(icon: "wind", title: "Gió", value: current.wind, color: .wosSuccess)
                detailCard(icon: "sun.max.fill", title: "UV", value: current.uv, color: .wosWarning)
            }
            .padding(.horizontal, 16)
        }
    }

    private func detailCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.wosTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.wosPanelAlt)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.wosBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.wosTextMuted)
            .padding(.horizontal, 16)
    }
}

#Preview {
    WeatherAppView()
}
