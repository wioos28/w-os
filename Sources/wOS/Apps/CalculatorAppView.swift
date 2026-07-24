// CalculatorAppView.swift
// Ported 1:1 from src/screens/CalculatorScreen.js
import SwiftUI

struct CalculatorAppView: View {
    @State private var display = "0"
    @State private var previous: Double?
    @State private var op: String?
    @State private var newNumber = true

    private let rows: [[String]] = [
        ["C", "⌫", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 4) {
                Spacer()
                if let op, let previous {
                    Text("\(formatted(previous)) \(op)").font(.system(size: 18)).foregroundColor(Color(hex: "888888"))
                }
                Text(display).font(.system(size: 52, weight: .light)).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.4)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
            .frame(maxHeight: .infinity)

            VStack(spacing: 10) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { key in
                            button(key, wide: key == "0" && row.count == 3)
                        }
                    }
                }
            }
            .padding(10).padding(.bottom, 16)
        }
        .background(Color.wosBackground)
    }

    private func button(_ key: String, wide: Bool) -> some View {
        Button(action: { tap(key) }) {
            Text(key)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .frame(width: wide ? nil : nil)
        }
        .background(bg(key))
        .cornerRadius(16)
        .overlay(isDigit(key) ? RoundedRectangle(cornerRadius: 16).stroke(Color.wosBorder) : nil)
        .frame(maxWidth: wide ? .infinity : nil)
    }

    private func isDigit(_ k: String) -> Bool { Int(k) != nil || k == "." }

    private func bg(_ key: String) -> Color {
        if ["÷", "×", "−", "+", "="].contains(key) { return .wosAccent }
        if ["C", "⌫", "%"].contains(key) { return Color(hex: "374151") }
        return Color(hex: "1a1a1a")
        return Color(hex: "1a1a1a")
    }

    private func tap(_ key: String) {
        switch key {
        case "C": display = "0"; previous = nil; op = nil; newNumber = true
        case "⌫": display = display.count > 1 ? String(display.dropLast()) : "0"
        case ".":
            if !display.contains(".") { display += "." }
        case "+", "−", "×", "÷":
            previous = Double(display)
            op = key
            newNumber = true
        case "%":
            if let val = Double(display) {
                display = formatted(val / 100)
            }
        case "=":
            calculate()
        default:
            if newNumber { display = key; newNumber = false }
            else { display = display == "0" ? key : display + key }
        }
    }

    private func calculate() {
        guard let previous, let op, let current = Double(display) else { return }
        var result: Double = 0
        switch op {
        case "+": result = previous + current
        case "−": result = previous - current
        case "×": result = previous * current
        case "÷": result = current != 0 ? previous / current : Double.nan
        default: break
        }
        display = result.isNaN ? "Error" : formatted(result)
        self.previous = nil
        self.op = nil
        newNumber = true
    }

    private func formatted(_ v: Double) -> String {
        if v == v.rounded() && abs(v) < 1e12 { return String(format: "%.0f", v) }
        return String(v).prefix(12).description
    }
}
