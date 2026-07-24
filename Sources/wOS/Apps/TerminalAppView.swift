// TerminalAppView.swift
// Beautiful terminal with syntax highlighting and enhanced commands.
import SwiftUI

struct TerminalAppView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var history: [TerminalLine] = [
        TerminalLine(text: "W OS Terminal v2.1.0 (Swift Native)", type: .system),
        TerminalLine(text: "Type \"help\" for available commands", type: .system),
        TerminalLine(text: "", type: .output)
    ]
    @State private var input = ""
    @State private var appears = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Terminal output
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(Array(history.enumerated()), id: \.offset) { idx, line in
                            Text(line.text)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(lineColor(line.type))
                                .id(idx)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(hex: "0c0c0c"))
                .onChange(of: history.count) { _ in
                    withAnimation { proxy.scrollTo(history.count - 1, anchor: .bottom) }
                }
            }

            // Input bar
            HStack(spacing: 8) {
                Text("❯")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.wosAccent)

                TextField("", text: $input, prompt: Text("Nhập lệnh...").foregroundColor(Color.wosTextDisabled))
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(hex: "00ff41"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused)
                    .onSubmit(runCommand)

                Button(action: runCommand) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(input.isEmpty ? Color.wosTextDisabled : .wosAccent)
                }
                .disabled(input.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "111111"))
        }
        .background(Color(hex: "0c0c0c"))
        .onAppear { focused = true }
    }

    // MARK: - Colors

    private func lineColor(_ type: LineType) -> Color {
        switch type {
        case .system: return Color.wosAccent
        case .command: return .white
        case .output: return Color(hex: "00ff41")
        case .error: return .wosDanger
        case .warning: return .wosWarning
        case .success: return .wosSuccess
        case .info: return .wosInfo
        }
    }

    // MARK: - Command Parser

    private func runCommand() {
        let cmd = input.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }

        history.append(TerminalLine(text: "❯ \(cmd)", type: .command))

        let parts = cmd.split(separator: " ", maxSplits: 1).map(String.init)
        let base = parts.first ?? ""
        let args = parts.count > 1 ? parts[1] : ""

        switch base {
        case "clear":
            history = [TerminalLine(text: "W OS Terminal v2.1.0 (Swift Native)", type: .system), TerminalLine(text: "", type: .output)]
            input = ""
            return

        case "echo":
            history.append(TerminalLine(text: args, type: .output))

        case "help":
            history.append(TerminalLine(text: helpText, type: .info))

        case "pwd":
            history.append(TerminalLine(text: "/home/user", type: .output))

        case "whoami":
            history.append(TerminalLine(text: systemState.userName.isEmpty ? "user" : systemState.userName, type: .output))

        case "date":
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "vi_VN")
            formatter.dateFormat = "EEEE, d MMMM yyyy 'at' HH:mm:ss"
            history.append(TerminalLine(text: formatter.string(from: Date()), type: .output))

        case "uname":
            history.append(TerminalLine(text: "W OS 2.1.0 - arm64 - Swift Native", type: .output))

        case "ls":
            history.append(TerminalLine(text: "Documents    Downloads    Pictures    Music    Videos    .config", type: .output))

        case "uptime":
            history.append(TerminalLine(text: "up ∞ days, 0:00", type: .output))

        case "neofetch":
            history.append(TerminalLine(text: neofetchText, type: .info))

        case "bootinfo":
            history.append(TerminalLine(text: bootInfoText, type: .info))

        case "open":
            let appId = args.lowercased().trimmingCharacters(in: .whitespaces)
            if !appId.isEmpty {
                systemState.openApp(appId)
                history.append(TerminalLine(text: "Opening \(appId)...", type: .success))
            } else {
                history.append(TerminalLine(text: "Usage: open <app-name>", type: .warning))
            }

        case "lock", "shutdown":
            history.append(TerminalLine(text: "Locking system...", type: .warning))
            input = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { systemState.screen = .lock }
            return

        case "reboot":
            history.append(TerminalLine(text: "Rebooting...", type: .warning))
            input = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { systemState.rebootThenDesktop() }
            return

        case "version":
            history.append(TerminalLine(text: "W OS v2.1.0 (Swift Native Build)", type: .output))

        case "apps":
            let apps = SystemAppsData.list.map { $0.id }.joined(separator: ", ")
            history.append(TerminalLine(text: "System apps: \(apps)", type: .output))

        case "wallpaper":
            history.append(TerminalLine(text: "Current wallpaper: \(systemState.wallpaper)", type: .output))

        default:
            history.append(TerminalLine(text: "Command not found: \(base). Type 'help' for available commands.", type: .error))
        }

        history.append(TerminalLine(text: "", type: .output))
        input = ""
    }

    // MARK: - Boot Info

    private var bootInfoText: String {
        switch systemState.bootDriveMode {
        case .none: return "No boot drive mounted."
        case .selfBuild(let source): return "Mounted self-built boot drive from: \(source)"
        case .adminBuilt: return "Mounted Admin-built boot drive."
        }
    }

    // MARK: - Help Text

    private let helpText = """
    Available commands:
      help       - Show this help
      clear      - Clear terminal
      echo       - Print text
      ls         - List files
      pwd        - Print working directory
      whoami     - Show current user
      date       - Show current date
      uname      - Show OS info
      version    - Show version
      uptime     - Show uptime
      apps       - List system apps
      wallpaper  - Show current wallpaper
      neofetch   - System info with style
      bootinfo   - Show mounted boot drive
      reboot     - Reboot system
      shutdown   - Lock screen
      lock       - Lock screen
      open       - Open an app
      exit       - Close terminal
    """

    // MARK: - Neofetch

    private let neofetchText = """
        ___      W OS 2.1.0
       (o o)     Kernel: Swift / SwiftUI
      (  V  )    Shell: WOS-Term
       \\___/     Uptime: ∞
                 Packages: 16
                 Memory: 2GB / 4GB
                 Resolution: Auto
                 Theme: Dark
    """
}

// MARK: - Models

enum LineType {
    case system, command, output, error, warning, success, info
}

struct TerminalLine {
    let text: String
    let type: LineType
}

#Preview {
    TerminalAppView()
        .environmentObject(SystemState())
}
