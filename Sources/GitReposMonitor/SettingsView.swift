import SwiftUI

struct SettingsView: View {
    @ObservedObject var scanner: RepoScanner
    @State private var newPath: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Settings")
                    .font(.headline)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                // Scan paths
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "folder.badge.gearshape")
                            .foregroundStyle(.blue)
                        Text("Scan Directories")
                            .font(.caption.bold())
                    }

                    ForEach(scanner.scanPaths, id: \.self) { path in
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .font(.caption2)
                                .foregroundStyle(.blue.opacity(0.6))
                            Text(path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            Button {
                                withAnimation { scanner.removeScanPath(path) }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.6))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        )
                    }

                    HStack(spacing: 6) {
                        TextField("~/path/to/scan", text: $newPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.caption, design: .monospaced))

                        Button {
                            let path = newPath.trimmingCharacters(in: .whitespaces)
                            guard !path.isEmpty else { return }
                            withAnimation {
                                scanner.addScanPath(path)
                            }
                            newPath = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newPath.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.caption2)
                        Text("Depth: 4 levels. Excludes node_modules, .build, vendor.")
                            .font(.caption2)
                    }
                    .foregroundStyle(.tertiary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 0.5)
                )

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("Info")
                            .font(.caption.bold())
                    }

                    VStack(spacing: 4) {
                        InfoRow(label: "Refresh interval", value: "2 minutes")
                        InfoRow(label: "Repos found", value: "\(scanner.repos.count)")
                        InfoRow(label: "Dirty repos", value: "\(scanner.dirtyCount)", color: scanner.dirtyCount > 0 ? .orange : nil)
                        InfoRow(label: "Total staged files", value: "\(scanner.stagedCount)", color: scanner.stagedCount > 0 ? .yellow : nil)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 0.5)
                )
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .frame(width: 400)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var color: Color? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(color ?? .secondary)
        }
    }
}
