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
                Divider()
                Button {
                    withAnimation { showSettings = false }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.caption)
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
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
