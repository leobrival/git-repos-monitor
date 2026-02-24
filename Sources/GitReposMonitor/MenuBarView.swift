import SwiftUI

struct MenuBarView: View {
    @ObservedObject var scanner: RepoScanner
    @Binding var showSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Git Repos")
                        .font(.headline)
                    Text("\(scanner.repos.count) repos found")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if scanner.isScanning {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            // Stats bar
            HStack(spacing: 12) {
                StatPill(
                    icon: "exclamationmark.circle.fill",
                    count: scanner.dirtyCount,
                    label: "dirty",
                    color: .orange
                )
                if scanner.stagedCount > 0 {
                    StatPill(
                        icon: "tray.full.fill",
                        count: scanner.stagedCount,
                        label: "staged",
                        color: .yellow
                    )
                }
                StatPill(
                    icon: "checkmark.circle.fill",
                    count: scanner.repos.count - scanner.dirtyCount,
                    label: "clean",
                    color: .green
                )

                Spacer()

                Toggle(isOn: $scanner.showCleanRepos) {
                    Text("All")
                        .font(.caption2)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()

            if scanner.filteredRepos.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: scanner.showCleanRepos ? "magnifyingglass" : "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(scanner.showCleanRepos ? Color.secondary : Color.green)
                    Text(scanner.showCleanRepos ? "No repos found" : "All repos are clean")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !scanner.showCleanRepos && scanner.repos.count > 0 {
                        Text("Toggle 'All' to see \(scanner.repos.count) repos")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(scanner.filteredRepos) { repo in
                            RepoCard(repo: repo)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            }

            Divider()

            // Footer
            HStack(spacing: 0) {
                Button {
                    withAnimation { scanner.scan() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .help("Rescan")

                Text("Updated \(scanner.lastScanAgo)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 6)

                Spacer()

                Button {
                    withAnimation { showSettings = true }
                } label: {
                    Image(systemName: "gear")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .help("Settings")

                Divider()
                    .frame(height: 12)
                    .padding(.horizontal, 8)

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Quit")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .frame(width: 400)
    }
}

// MARK: - Stat Pill (shared pattern)

struct StatPill: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.caption.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Repo Card

struct RepoCard: View {
    let repo: GitRepo
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top: name + branch + actions
            HStack(spacing: 6) {
                Circle()
                    .fill(repo.status.color)
                    .frame(width: 8, height: 8)

                Text(repo.name)
                    .font(.system(.callout, design: .default).bold())
                    .lineLimit(1)

                Text(repo.branch)
                    .font(.system(.caption2, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(3)

                Spacer()

                // Actions
                HStack(spacing: 2) {
                    Button {
                        openInTerminal(repo.path)
                    } label: {
                        Image(systemName: "terminal")
                            .font(.caption2)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.borderless)
                    .help("Open in Terminal")

                    Button {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: repo.path)
                    } label: {
                        Image(systemName: "folder")
                            .font(.caption2)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.borderless)
                    .help("Open in Finder")
                }
            }

            // Status badges
            if repo.status.isDirty {
                HStack(spacing: 6) {
                    if repo.status.stagedCount > 0 {
                        ChangeBadge(
                            icon: "tray.full.fill",
                            count: repo.status.stagedCount,
                            label: "staged",
                            color: .orange
                        )
                    }
                    if repo.status.unstagedCount > 0 {
                        ChangeBadge(
                            icon: "pencil",
                            count: repo.status.unstagedCount,
                            label: "modified",
                            color: .yellow
                        )
                    }
                    if repo.status.untrackedCount > 0 {
                        ChangeBadge(
                            icon: "questionmark.circle",
                            count: repo.status.untrackedCount,
                            label: "untracked",
                            color: .secondary
                        )
                    }
                }
                .padding(.leading, 14)
            }

            // Last commit + path
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                        Text(repo.lastCommitAgo)
                        Text("·")
                        Text(repo.lastCommitMessage)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                    Text(repo.displayPath)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.quaternary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.leading, 14)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered
                    ? Color(nsColor: .controlBackgroundColor).opacity(0.5)
                    : Color(nsColor: .controlBackgroundColor).opacity(0.3)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    repo.status.isDirty
                        ? repo.status.color.opacity(0.15)
                        : Color(nsColor: .separatorColor).opacity(0.2),
                    lineWidth: 0.5
                )
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private func openInTerminal(_ path: String) {
        let escapedPath = path.replacingOccurrences(of: "\"", with: "\\\"")
        let script = "tell application \"Terminal\" to do script \"cd \(escapedPath)\""
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }
}

// MARK: - Change Badge

struct ChangeBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundStyle(color)
            Text("\(count) \(label)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.08))
        .cornerRadius(3)
    }
}
