// CalendarAppView.swift
// Beautiful calendar with month navigation and event cards.
import SwiftUI

struct CalendarAppView: View {
    private let dayNames = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
    private let monthNames = ["Tháng 1","Tháng 2","Tháng 3","Tháng 4","Tháng 5","Tháng 6",
                              "Tháng 7","Tháng 8","Tháng 9","Tháng 10","Tháng 11","Tháng 12"]

    @State private var month: Int
    @State private var year: Int
    @State private var selectedDay: Int
    @State private var appears = false

    private let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())

    init() {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        _month = State(initialValue: (comps.month ?? 1) - 1)
        _year = State(initialValue: comps.year ?? 2026)
        _selectedDay = State(initialValue: comps.day ?? 1)
    }

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: dateFor(day: 1))?.count ?? 30
    }

    private var firstWeekday: Int {
        Calendar.current.component(.weekday, from: dateFor(day: 1)) - 1
    }

    private func dateFor(day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month + 1
        comps.day = day
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
            // Header with month navigation
            header

            // Day names row
            dayNamesRow

            // Calendar grid
            calendarGrid

            // Selected day info
            selectedDayCard

            Spacer()
        }
        .background(Color.wosBackground)
        .onAppear {
            withAnimation(.spring(response: 0.5)) { appears = true }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { withAnimation { prevMonth() } }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.wosAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.wosPanelAlt)
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(monthNames[month])
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(year)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.wosTextSecondary)
            }

            Spacer()

            Button(action: { withAnimation { nextMonth() } }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.wosAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.wosPanelAlt)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Day Names

    private var dayNamesRow: some View {
        HStack {
            ForEach(dayNames, id: \.self) { d in
                Text(d)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.wosTextMuted)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private func dayCell(_ day: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) { selectedDay = day }
        }) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.system(size: 15, weight: day == selectedDay ? .bold : .regular, design: .rounded))
                    .foregroundColor(dayTextColor(day))

                if isToday(day) && day != selectedDay {
                    Circle()
                        .fill(Color.wosAccent)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 40, height: 40)
            .background(dayBackgroundColor(day))
            .clipShape(Circle())
        }
    }

    private func dayTextColor(_ day: Int) -> Color {
        if day == selectedDay { return .white }
        if isToday(day) { return .wosAccent }
        return Color.wosTextPrimary
    }

    private func dayBackgroundColor(_ day: Int) -> Color {
        if day == selectedDay { return Color.wosAccent }
        return Color.clear
    }

    // MARK: - Selected Day Card

    private var selectedDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(.wosAccent)
                Text("Sự kiện ngày \(selectedDay)/\(month + 1)/\(year)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.wosAccent.opacity(0.15))
                    .frame(width: 4, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Không có sự kiện")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.wosTextSecondary)
                    Text("Nhấn để thêm sự kiện mới")
                        .font(.system(size: 12))
                        .foregroundColor(Color.wosTextDisabled)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.wosPanel)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.wosBorder))
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Navigation

    private func prevMonth() {
        if month == 0 { month = 11; year -= 1 } else { month -= 1 }
    }

    private func nextMonth() {
        if month == 11 { month = 0; year += 1 } else { month += 1 }
    }
}

#Preview {
    CalendarAppView()
}
