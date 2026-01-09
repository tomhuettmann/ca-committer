import Foundation

struct Contributor: Hashable {
    let name: String
    let email: String
}

struct GitRepository {
    private let path: String

    init?(path: String) {
        self.path = path
        guard isValidGitRepo(at: path) else { return nil }
    }

    private func isValidGitRepo(at path: String) -> Bool {
        let process = Process()
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "rev-parse", "--is-inside-work-tree"]

        try? process.run()
        process.waitUntilExit()

        return process.terminationStatus == 0
    }

    func getRecentContributors(lastCommits: Int) -> [Contributor] {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "log", "--format=%an|%ae", "-n", "\(lastCommits)"]

        try? process.run()
        process.waitUntilExit()

        guard
            process.terminationStatus == 0,
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        else { return [] }

        var seen = Set<Contributor>()
        return output
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .compactMap {
                let parts = $0.components(separatedBy: "|")
                guard
                    parts.count == 2,
                    let name = parts.first,
                    let email = parts.last,
                    !name.isEmpty,
                    !email.isEmpty,
                    !email.contains("noreply.github.com")
                else { return nil }
                return Contributor(name: name, email: email)
            }
            .filter { seen.insert($0).inserted }
    }
}
