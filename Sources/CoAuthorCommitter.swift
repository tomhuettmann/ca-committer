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

    func run() throws {
        print("Working in directory: \(directory)")

        // TODO: Add your co-author commit logic here
    }
}
