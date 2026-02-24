import SwiftUI

struct SettingsView: View {
    @ObservedObject var scanner: RepoScanner
    @State private var newPath: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "gear")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle().fill(Theme.border).frame(height: 1)

            VStack(alignment: .leading, spacing: 8) {
                // Scan paths
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan Directories")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    ForEach(scanner.scanPaths, id: \.self) { path in
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.textMuted)
                            Text(path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            Button {
                                withAnimation { scanner.removeScanPath(path) }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(Theme.textMuted)
                                    .frame(width: 16, height: 16)
                                    .background(Theme.textMuted.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusSm)
                                .fill(Theme.bgElevated)
                        )
                    }

                    HStack(spacing: 6) {
                        TextField("~/path/to/scan", text: $newPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11, design: .monospaced))

                        Button {
                            let path = newPath.trimmingCharacters(in: .whitespaces)
                            guard !path.isEmpty else { return }
                            withAnimation { scanner.addScanPath(path) }
                            newPath = ""
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                                .frame(width: 22, height: 22)
                                .background(Theme.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radiusSm)
                                        .strokeBorder(Theme.border, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.borderless)
                        .disabled(newPath.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    Text("Depth: 4 levels. Excludes node_modules, .build, vendor.")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                        .fill(Theme.bgCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                        .strokeBorder(Theme.borderSubtle, lineWidth: 1)
                )

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Info")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    VStack(spacing: 6) {
                        InfoRow(label: "Refresh interval", value: "2 minutes")
                        InfoRow(label: "Repos found", value: "\(scanner.repos.count)")
                        InfoRow(label: "Dirty repos", value: "\(scanner.dirtyCount)", color: scanner.dirtyCount > 0 ? Theme.warning : nil)
                        InfoRow(label: "Total staged files", value: "\(scanner.stagedCount)", color: scanner.stagedCount > 0 ? Theme.error : nil)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                        .fill(Theme.bgCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                        .strokeBorder(Theme.borderSubtle, lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 400)
        .background(Theme.bg)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var color: Color? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(color ?? Theme.textTertiary)
        }
    }
}
