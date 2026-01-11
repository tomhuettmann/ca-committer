import ArgumentParser
import Foundation
import SwiftTUI

@main
struct CoAuthorCommitter: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ca-committer",
        abstract: "Git commit with co-authors support",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "The git repository directory")
    var directory: String = FileManager.default.currentDirectoryPath

    @Option(name: .shortAndLong, help: "Amount of commits to scan at once")
    var numberOfCommitsPerPagination: Int = 100

    func run() throws {
        guard let repo = GitRepository(path: directory) else {
            throw ValidationError("Not a git repository: \(directory)")
        }

        let service = ContributorService(repository: repo, pageSize: numberOfCommitsPerPagination)
        
        Application(rootView: ContentView(
            service: service,
            myself: repo.myself,
            commandName: Self.configuration.commandName,
            version: Self.configuration.version
        )).start()
    }
}
