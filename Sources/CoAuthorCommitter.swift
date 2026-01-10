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
        guard let repo = GitRepository(path: directory) else { throw ValidationError("Not a git repository: \(directory)") }

        var pagination = 0
        var allContributors: [Contributor] = repo.getRecentContributors(amountOfCommits: numberOfCommitsPerPagination, skipFirstCommits: 0)
        var seenContributors = Set(allContributors)
        
        Application(rootView: ContentView(
            contributors: allContributors,
            amountOfAnalyzedCommits: numberOfCommitsPerPagination,
            myself: repo.myself,
            commandName: Self.configuration.commandName,
            version: Self.configuration.version,
            onLoadMoreContributors: {
                pagination += 1
                let newContributors = repo.getRecentContributors(
                    amountOfCommits: numberOfCommitsPerPagination,
                    skipFirstCommits: pagination * numberOfCommitsPerPagination,
                    excluding: seenContributors
                )
                allContributors.append(contentsOf: newContributors)
                seenContributors.formUnion(newContributors)
                let totalAnalyzed = (pagination + 1) * numberOfCommitsPerPagination
                return (allContributors, totalAnalyzed)
            }
        )).start()
    }
}
