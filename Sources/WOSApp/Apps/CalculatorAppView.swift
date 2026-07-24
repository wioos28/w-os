// CalculatorAppView.swift
// Modern calculator with glass buttons and haptic feedback.
import SwiftUI
import WOSCore

struct CalculatorAppView: View {
    @State private var display = "0"
    @State private var previous: Double?
    @State private var op: String?
    @State private var newNumber = true
    @State private var pressedKey: String?
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private let rows: [[String]] = [
        ["C", "⌫", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Display
            VStack(alignment: .trailing, spacing: 8) {
                Spacer()

                if let op, let previous {
                    HStack(spacing: 8) {
                        Text(formatted(previous))
                        Text(op)
                            .foregroundColor(.wosAccent)
                    }
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.wosTextMuted)
                }

                Text(display)
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .padding(.trailing, 4)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity)

            // Button grid
            VStack(spacing: 12) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            calcButton(key, wide: key == "0" && row.count == 3)
                        }
                    }
                }
            }
            .padding(12)
            .padding(.bottom, 20)
        }
        .background(Color.wosBackground)
    }

    // MARK: - Button

    private func calcButton(_ key: String, wide: Bool) -> some View {
        Button(action: { tap(key) }) {
            Text(key)
                .font(.system(size: key == "=" ? 26 : 22, weight: .medium, design: .rounded))
                .foregroundColor(buttonTextColor(key))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    ZStack {
                        if pressedKey == key {
                            buttonColor(key).opacity(0.8)
                        } else {
                            buttonColor(key)
                        }
                    }
                )
                .cornerRadius(18)
                .shadow(color: buttonShadowColor(key), radius: 8, x: 0, y: 4)
                .scaleEffect(pressedKey == key ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: pressedKey)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: wide ? .infinity : nil)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            pressedKey = pressing ? key : nil
        }, perform: {})
    }

    // MARK: - Colors

    private func buttonColor(_ key: String) -> Color {
        if key == "=" { return Color.wosAccent }
        if key == "C" || key == "⌫" || key == "%" { return Color(hex: "2a2a2e") }
        if ["÷", "×", "−", "+"].contains(key) { return Color(hex: "3b3b40") }
        return Color(hex: "1c1c1e")
    }

    private func buttonTextColor(_ key: String) -> Color {
        if key == "=" { return .white }
        if ["÷", "×", "−", "+"].contains(key) { return .wosAccentLight }
        return .white
    }

    private func buttonShadowColor(_ key: String) -> Color {
        if key == "=" { return Color.wosAccent.opacity(0.3) }
        return Color.black.opacity(0.2)
    }

    // MARK: - Logic

    private func tap(_ key: String) {
        haptic.impactOccurred()

        switch key {
        case "C":
            display = "0"; previous = nil; op = nil; newNumber = true
        case "⌫":
            display = display.count > 1 ? String(display.dropLast()) : "0"
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

#Preview {
    CalculatorAppView()
}
