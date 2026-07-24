// CalendarAppView.swift
// Ported 1:1 from src/screens/CalendarScreen.js — month grid with prev/next navigation.
import SwiftUI

struct CalendarAppView: View {
    private let dayNames = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
    private let monthNames = ["Tháng 1","Tháng 2","Tháng 3","Tháng 4","Tháng 5","Tháng 6","Tháng 7","Tháng 8","Tháng 9","Tháng 10","Tháng 11","Tháng 12"]

    @State private var month: Int
    @State private var year: Int
    @State private var selectedDay: Int

    private let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())

    init() {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        _month = State(initialValue: (comps.month ?? 1) - 1)
        _year = State(initialValue: comps.year ?? 2026)
        _selectedDay = State(initialValue: comps.day ?? 1)
    }

    private var daysInMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: dateFor(day: 1))!
        return range.count
    }

    private var firstWeekday: Int {
        Calendar.current.component(.weekday, from: dateFor(day: 1)) - 1
    }

    private func dateFor(day: Int) -> Date {
        var comps = DateComponents(); comps.year = year; comps.month = month + 1; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    private var cells: [Int?] {
        var arr: [Int?] = Array(repeating: nil, count: firstWeekday)
        arr += (1...daysInMonth).map { $0 }
        return arr
    }

    private func isToday(_ day: Int?) -> Bool {
        guard let day else { return false }
        return day == today.day && month + 1 == today.month && year == today.year
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: prevMonth) { Image(systemName: "chevron.left").font(.system(size: 20)).foregroundColor(.wosAccent) }
                Spacer()
                Text("\(monthNames[month]) \(year)").font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Button(action: nextMonth) { Image(systemName: "chevron.right").font(.system(size: 20)).foregroundColor(.wosAccent) }
            }
            .padding(16)

            HStack {
                ForEach(dayNames, id: \.self) { d in
                    Text(d).font(.system(size: 12)).foregroundColor(Color(hex: "666666")).frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
            .overlay(Divider().background(Color(hex: "1a1a1a")), alignment: .bottom)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        Text("\(day)")
                            .font(.system(size: 14, weight: day == selectedDay ? .semibold : .regular))
                            .foregroundColor(day == selectedDay ? .white : (isToday(day) ? .wosAccent : Color(hex: "cccccc")))
                            .frame(width: 36, height: 36)
                            .background(day == selectedDay ? Color.wosAccent : .clear)
                            .overlay(Circle().stroke(isToday(day) && day != selectedDay ? Color.wosAccent : .clear))
                            .clipShape(Circle())
                            .onTapGesture { selectedDay = day }
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
            }
            .padding(8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Sự kiện \(selectedDay)/\(month + 1)/\(year)").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                HStack(spacing: 10) {
                    Circle().fill(Color.wosAccent).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Không có sự kiện").font(.system(size: 14)).foregroundColor(Color(hex: "888888"))
                        Text("Nhấn để thêm sự kiện mới").font(.system(size: 12)).foregroundColor(Color(hex: "555555"))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(hex: "111111"))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "1a1a1a")))
            .padding(12)
            Spacer()
        }
        .background(Color.wosBackground)
    }

    private func prevMonth() {
        if month == 0 { month = 11; year -= 1 } else { month -= 1 }
    }
    private func nextMonth() {
        if month == 11 { month = 0; year += 1 } else { month += 1 }
    }
}
