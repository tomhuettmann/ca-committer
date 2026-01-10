import Foundation

struct GitRepository {
    private let path: String
    let myself: Contributor?

    init?(path: String) {
        self.path = path
        guard Self.isValidGitRepo(at: path) else { return nil }
        self.myself = Self.loadMyself(at: path)
    }

    private func executeGitCommand(_ arguments: [String]) -> String? {
        Self.executeGitCommand(at: path, arguments: arguments)
    }

    private static func executeGitCommand(at path: String, arguments: [String]) -> String? {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path] + arguments
        
        try? process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else { return nil }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }

    private static func isValidGitRepo(at path: String) -> Bool {
        executeGitCommand(at: path, arguments: ["rev-parse", "--is-inside-work-tree"]) != nil
    }

    private static func loadMyself(at path: String) -> Contributor? {
        guard let output = executeGitCommand(at: path, arguments: ["config", "--get-regexp", "^user\\.(name|email)$"]) else {
            return nil
        }

        var name: String?
        var email: String?

        for line in output.components(separatedBy: .newlines) {
            let parts = line.components(separatedBy: " ")
            guard parts.count >= 2 else { continue }

            let key = parts[0]
            let value = parts.dropFirst().joined(separator: " ")

            if key == "user.name" {
                name = value
            } else if key == "user.email" {
                email = value
            }
        }

        guard
            let name, !name.isEmpty,
            let email, !email.isEmpty
        else { return nil }

        return Contributor(name: name, email: email)
    }

    func getRecentContributors(amountOfCommits: Int, skipFirstCommits: Int = 0, excluding: Set<Contributor> = []) -> [Contributor] {
        guard let output = executeGitCommand(["log", "--format=%an|%ae", "--skip", "\(skipFirstCommits)", "-n", "\(amountOfCommits)"]) else {
            return []
        }

        var seen = excluding
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
            .filter { $0 != myself && seen.insert($0).inserted }
    }
}
