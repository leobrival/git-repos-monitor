import Foundation

@MainActor
final class RepoScanner: ObservableObject {
    @Published var repos: [GitRepo] = []
    @Published var isScanning = false
    @Published var lastScan: Date = Date()
    @Published var scanPaths: [String] = [] {
        didSet {
            let encoded = try? JSONEncoder().encode(scanPaths)
            UserDefaults.standard.set(encoded, forKey: "scanPaths")
        }
    }
    @Published var showCleanRepos = false {
        didSet {
            UserDefaults.standard.set(showCleanRepos, forKey: "showCleanRepos")
        }
    }

    var filteredRepos: [GitRepo] {
        if showCleanRepos {
            return repos
        }
        return repos.filter { $0.status.isDirty }
    }

    var dirtyCount: Int {
        repos.filter { $0.status.isDirty }.count
    }

    var stagedCount: Int {
        repos.reduce(0) { $0 + $1.status.stagedCount }
    }

    var lastScanAgo: String {
        let interval = Date().timeIntervalSince(lastScan)
        if interval < 5 { return "just now" }
        if interval < 60 { return "\(Int(interval))s ago" }
        return "\(Int(interval / 60))m ago"
    }

    private var refreshTimer: Timer?

    init() {
        if let data = UserDefaults.standard.data(forKey: "scanPaths"),
           let paths = try? JSONDecoder().decode([String].self, from: data) {
            scanPaths = paths
        } else {
            scanPaths = [
                NSHomeDirectory() + "/Developer",
                NSHomeDirectory() + "/Desktop"
            ]
        }
        showCleanRepos = UserDefaults.standard.bool(forKey: "showCleanRepos")

        scan()
        startRefreshTimer()
    }

    func scan() {
        isScanning = true
        let paths = scanPaths

        Task {
            let found = await scanRepos(paths: paths)
            self.repos = found
            self.isScanning = false
            self.lastScan = Date()
        }
    }

    nonisolated func scanRepos(paths: [String]) async -> [GitRepo] {
        var found: [GitRepo] = []

        for basePath in paths {
            let gitDirs = Self.findGitRepos(in: basePath)
            for gitDir in gitDirs {
                let repoPath = (gitDir as NSString).deletingLastPathComponent
                if let repo = Self.inspectRepo(at: repoPath) {
                    found.append(repo)
                }
            }
        }

        found.sort()
        return found
    }

    func addScanPath(_ path: String) {
        let expanded = (path as NSString).expandingTildeInPath
        guard !scanPaths.contains(expanded) else { return }
        scanPaths.append(expanded)
    }

    func removeScanPath(_ path: String) {
        scanPaths.removeAll { $0 == path }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scan()
            }
        }
    }

    // Find all .git directories recursively (max depth 4)
    nonisolated private static func findGitRepos(in basePath: String) -> [String] {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/find")
        task.arguments = [
            basePath,
            "-maxdepth", "4",
            "-name", ".git",
            "-type", "d",
            "-not", "-path", "*/node_modules/*",
            "-not", "-path", "*/.build/*",
            "-not", "-path", "*/vendor/*",
            "-not", "-path", "*/.claude/*"
        ]
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        return output.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    // Inspect a single repo for status
    nonisolated private static func inspectRepo(at path: String) -> GitRepo? {
        let branch = runGit(in: path, args: ["rev-parse", "--abbrev-ref", "HEAD"])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !branch.isEmpty else { return nil }

        let statusOutput = runGit(in: path, args: ["status", "--porcelain"])
        let statusLines = statusOutput.components(separatedBy: "\n").filter { !$0.isEmpty }

        var staged = 0
        var unstaged = 0
        var untracked = 0

        for line in statusLines {
            guard line.count >= 2 else { continue }
            let x = line[line.startIndex]
            let y = line[line.index(line.startIndex, offsetBy: 1)]

            if x == "?" {
                untracked += 1
            } else {
                if x != " " && x != "?" { staged += 1 }
                if y != " " && y != "?" { unstaged += 1 }
            }
        }

        let status: RepoStatus
        if staged == 0 && unstaged == 0 && untracked == 0 {
            status = .clean
        } else {
            status = .dirty(staged: staged, unstaged: unstaged, untracked: untracked)
        }

        let logOutput = runGit(in: path, args: ["log", "-1", "--format=%aI%n%s"])
        let logLines = logOutput.components(separatedBy: "\n")

        var lastDate: Date? = nil
        var lastMessage = ""

        if logLines.count >= 2 {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            lastDate = formatter.date(from: logLines[0])
            lastMessage = logLines[1]
        }

        let name = (path as NSString).lastPathComponent

        return GitRepo(
            id: path,
            path: path,
            name: name,
            branch: branch,
            status: status,
            lastCommitDate: lastDate,
            lastCommitMessage: lastMessage
        )
    }

    nonisolated private static func runGit(in directory: String, args: [String]) -> String {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        task.arguments = args
        task.currentDirectoryURL = URL(fileURLWithPath: directory)
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return ""
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
