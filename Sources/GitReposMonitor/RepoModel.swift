import Foundation
import SwiftUI

enum RepoStatus: Comparable {
    case dirty(staged: Int, unstaged: Int, untracked: Int)
    case clean

    var isDirty: Bool {
        if case .clean = self { return false }
        return true
    }

    var color: Color {
        switch self {
        case .dirty(let staged, _, _):
            return staged > 0 ? .orange : .yellow
        case .clean:
            return .green
        }
    }

    var stagedCount: Int {
        if case .dirty(let staged, _, _) = self { return staged }
        return 0
    }

    var unstagedCount: Int {
        if case .dirty(_, let unstaged, _) = self { return unstaged }
        return 0
    }

    var untrackedCount: Int {
        if case .dirty(_, _, let untracked) = self { return untracked }
        return 0
    }

    var totalChanges: Int {
        stagedCount + unstagedCount + untrackedCount
    }

    static func < (lhs: RepoStatus, rhs: RepoStatus) -> Bool {
        switch (lhs, rhs) {
        case (.dirty, .clean): return true
        case (.clean, .dirty): return false
        case (.dirty(let ls, let lu, let lut), .dirty(let rs, let ru, let rut)):
            return (ls + lu + lut) > (rs + ru + rut)
        case (.clean, .clean): return false
        }
    }
}

struct GitRepo: Identifiable, Comparable {
    let id: String
    let path: String
    let name: String
    let branch: String
    let status: RepoStatus
    let lastCommitDate: Date?
    let lastCommitMessage: String

    var displayPath: String {
        path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }

    var lastCommitAgo: String {
        guard let date = lastCommitDate else { return "-" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        let days = Int(interval / 86400)
        if days == 1 { return "yesterday" }
        if days < 30 { return "\(days)d ago" }
        return "\(days / 30)mo ago"
    }

    static func < (lhs: GitRepo, rhs: GitRepo) -> Bool {
        if lhs.status.isDirty != rhs.status.isDirty {
            return lhs.status.isDirty
        }
        return lhs.status < rhs.status
    }
}
