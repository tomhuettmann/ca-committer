import ArgumentParser
import Foundation

@main
struct CoAuthorCommitter: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ca-committer",
        abstract: "Git commit with co-authors support"
    )

    @Option(name: .shortAndLong, help: "The git repository directory")
    var directory: String = FileManager.default.currentDirectoryPath

    @Option(name: .shortAndLong, help: "Amount of last commits to scan")
    var numberOfLastCommits: Int = 100

    func run() throws {
        guard let repo = GitRepository(path: directory) else { throw ValidationError("Not a git repository: \(directory)") }
        let contributors = repo.getRecentContributors(lastCommits: numberOfLastCommits)

        contributors.forEach { print($0) }
    }
}
