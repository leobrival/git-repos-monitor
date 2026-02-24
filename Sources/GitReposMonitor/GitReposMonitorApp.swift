import SwiftUI

@main
struct GitReposMonitorApp: App {
    @StateObject private var scanner = RepoScanner()
    @State private var showSettings = false

    var body: some Scene {
        MenuBarExtra {
            if showSettings {
                SettingsView(scanner: scanner)
                    .padding(.bottom, 4)
                Rectangle().fill(Theme.border).frame(height: 1)
                Button {
                    withAnimation { showSettings = false }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.bg)
            } else {
                MenuBarView(scanner: scanner, showSettings: $showSettings)
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "arrow.triangle.branch")
                if scanner.dirtyCount > 0 {
                    Text("\(scanner.dirtyCount)")
                } else {
                    Image(systemName: "checkmark")
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
