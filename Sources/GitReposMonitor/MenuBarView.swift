import SwiftUI

struct MenuBarView: View {
    @ObservedObject var scanner: RepoScanner
    @Binding var showSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Git Repos")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(scanner.repos.count) repos found")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                if scanner.isScanning {
                    ProgressView()
                        .scaleEffect(0.5)
                        .tint(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle().fill(Theme.border).frame(height: 1)

            // Stats bar
            HStack(spacing: 12) {
                StatPill(icon: "circle.fill", count: scanner.dirtyCount, label: "dirty", color: Theme.warning)
                if scanner.stagedCount > 0 {
                    StatPill(icon: "circle.fill", count: scanner.stagedCount, label: "staged", color: Theme.error)
                }
                StatPill(icon: "circle.fill", count: scanner.repos.count - scanner.dirtyCount, label: "clean", color: Theme.success)

                Spacer()

                Toggle(isOn: $scanner.showCleanRepos) {
                    Text("All")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                .tint(Theme.success)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Rectangle().fill(Theme.border).frame(height: 1)

            if scanner.filteredRepos.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: scanner.showCleanRepos ? "magnifyingglass" : "checkmark.circle")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(scanner.showCleanRepos ? Theme.textSecondary : Theme.success)
                    Text(scanner.showCleanRepos ? "No repos found" : "All repos are clean")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                    if !scanner.showCleanRepos && scanner.repos.count > 0 {
                        Text("Toggle 'All' to see \(scanner.repos.count) repos")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(scanner.filteredRepos) { repo in
                            RepoCard(repo: repo)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            }

            Rectangle().fill(Theme.border).frame(height: 1)

            // Footer
            HStack(spacing: 0) {
                Button {
                    withAnimation { scanner.scan() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.borderless)
                .help("Rescan")

                Text("Updated \(scanner.lastScanAgo)")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.leading, 6)

                Spacer()

                Button {
                    withAnimation { showSettings = true }
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.borderless)
                .help("Settings")

                Rectangle().fill(Theme.border).frame(width: 1, height: 12).padding(.horizontal, 8)

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textMuted)
                }
                .buttonStyle(.borderless)
                .help("Quit")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 400)
        .background(Theme.bg)
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 6))
                .foregroundStyle(color)
            Text("\(count)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
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
                    .frame(width: 6, height: 6)

                Text(repo.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Text(repo.branch)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))

                Spacer()

                HStack(spacing: 2) {
                    Button {
                        openInTerminal(repo.path)
                    } label: {
                        Image(systemName: "terminal")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.textMuted)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.borderless)
                    .help("Open in Terminal")

                    Button {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: repo.path)
                    } label: {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.textMuted)
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
                        ChangeBadge(count: repo.status.stagedCount, label: "staged", color: Theme.error)
                    }
                    if repo.status.unstagedCount > 0 {
                        ChangeBadge(count: repo.status.unstagedCount, label: "modified", color: Theme.warning)
                    }
                    if repo.status.untrackedCount > 0 {
                        ChangeBadge(count: repo.status.untrackedCount, label: "untracked", color: Theme.textSecondary)
                    }
                }
                .padding(.leading, 12)
            }

            // Last commit + path
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(repo.lastCommitAgo)
                    Text("·")
                    Text(repo.lastCommitMessage)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .font(.system(size: 10))
                .foregroundStyle(Theme.textMuted)

                Text(repo.displayPath)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.textMuted.opacity(0.6))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.leading, 12)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(isHovered ? Theme.bgCardHover : Theme.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .strokeBorder(
                    repo.status.isDirty ? repo.status.color.opacity(0.1) : Theme.borderSubtle,
                    lineWidth: 1
                )
        )
        .onHover { hovering in isHovered = hovering }
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
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Text("\(count)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
    }
}
