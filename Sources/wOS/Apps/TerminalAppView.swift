// TerminalAppView.swift
// Ported 1:1 from src/screens/TerminalScreen.js — full command interpreter.
import SwiftUI

struct TerminalAppView: View {
    @EnvironmentObject var systemState: SystemState
    @State private var history: [String] = ["W OS Terminal v2.1.0 (Swift Native)", "Type \"help\" for available commands", ""]
    @State private var input = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(history.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(line.hasPrefix("$") ? .wosAccent : Color(hex: "00ff41"))
                                .id(idx)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: history.count) { _ in
                    withAnimation { proxy.scrollTo(history.count - 1, anchor: .bottom) }
                }
            }
            HStack {
                Text("$").font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.wosAccent)
                TextField("", text: $input, prompt: Text("Nhập lệnh...").foregroundColor(Color(hex: "333333")))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(hex: "00ff41"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit(runCommand)
            }
            .padding(12)
            .background(Color(hex: "111111"))
        }
        .background(Color(hex: "0c0c0c"))
    }

    private func runCommand() {
        let cmd = input.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }
        history.append("$ \(cmd)")
        let parts = cmd.split(separator: " ", maxSplits: 1).map(String.init)
        let base = parts.first ?? ""
        let args = parts.count > 1 ? parts[1] : ""

        switch base {
        case "clear":
            history = ["W OS Terminal v2.1.0 (Swift Native)", ""]
            input = ""
            return
        case "echo": history.append(args)
        case "exit": return
        case "shutdown", "lock":
            history.append("Locking system...")
            input = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { systemState.screen = .lock }
            return
        case "reboot":
            history.append("Rebooting...")
            input = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { systemState.rebootThenDesktop() }
            return
        case "open":
            let appId = args.lowercased().trimmingCharacters(in: .whitespaces)
            if !appId.isEmpty { systemState.openApp(appId); history.append("Opening \(appId)...") }
            else { history.append("Usage: open <app-name>") }
        case "install":
            history.append("Installing from file...")
            history.append("Supported: source archive, repo URL")
        case "help":
            history.append(helpText)
        case "pwd": history.append("/home/user")
        case "whoami": history.append("user")
        case "date": history.append(Date().description)
        case "uname": history.append("W OS 2.1.0 - arm64 - Swift Native")
        case "ls": history.append("Documents  Downloads  Pictures  Music  Videos  .config")
        case "neofetch": history.append(neofetchText)
        case "bootinfo": history.append(bootInfoText)
        default: history.append("Command not found: \(base)")
        }
        history.append("")
        input = ""
    }

    private var bootInfoText: String {
        switch systemState.bootDriveMode {
        case .none: return "No boot drive mounted."
        case .selfBuild(let source): return "Mounted self-built boot drive from: \(source)"
        case .adminBuilt: return "Mounted Admin-built boot drive."
        }
    }

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
      neofetch   - System info with style
      bootinfo   - Show mounted boot drive
      reboot     - Reboot system
      shutdown   - Lock screen
      lock       - Lock screen
      open       - Open an app (e.g. open calculator, open appstore)
      install    - Install app from file
      exit       - Close terminal
    """

    private let neofetchText = """
        ___      W OS 2.1.0
       (o o)     Kernel: Swift / SwiftUI
      (  V  )    Shell: WOS-Term
       \\___/     Uptime: ∞
                 Packages: 16
                 Memory: 2GB / 4GB
    """
}
