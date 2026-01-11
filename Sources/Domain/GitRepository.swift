import Foundation

struct GitRepository {
    private enum Constants {
        static let gitExecutablePath = "/usr/bin/git"
        static let noReplyEmailDomain = "noreply.github.com"
    }
    
    private let path: String
    let myself: Contributor?
    let amountOfCommits: Int?

    init?(path: String) {
        self.path = path
        guard Self.isValidGitRepo(at: path) else { return nil }
        self.myself = Self.loadMyself(at: path)
        self.amountOfCommits = Self.countCommits(at: path)
    }

    private func executeGitCommand(_ arguments: [String]) -> (Bool, String?) {
        Self.executeGitCommand(at: path, arguments: arguments)
    }

    private static func executeGitCommand(at path: String, arguments: [String]) -> (Bool, String?) {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: Constants.gitExecutablePath)
        process.arguments = ["-C", path] + arguments
        
        try? process.run()
        process.waitUntilExit()

        guard let rawOutput = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) else {
            return (false, nil)
        }
        
        let normalizedOutput = rawOutput
            .replacingOccurrences(of: "\t", with: "    ")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        
        return (process.terminationStatus == 0, normalizedOutput)
    }

    private static func isValidGitRepo(at path: String) -> Bool {
        executeGitCommand(at: path, arguments: ["rev-parse", "--is-inside-work-tree"]).0
    }

    private static func loadMyself(at path: String) -> Contributor? {
        let (success, output) = executeGitCommand(at: path, arguments: ["config", "--get-regexp", "^user\\.(name|email)$"])
        guard success, let output else { return nil }

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

    private static func countCommits(at path: String) -> Int? {
        let (success, output) = executeGitCommand(at: path, arguments: ["rev-list", "--count", "HEAD"])
        guard success, let output else { return nil }

        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func getRecentContributors(amountOfCommits: Int, skipFirstCommits: Int = 0, excluding: Set<Contributor> = []) -> [Contributor] {
        let (success, output) = executeGitCommand(["log", "--format=%an|%ae", "--skip", "\(skipFirstCommits)", "-n", "\(amountOfCommits)"])
        guard success, let output else { return [] }

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
                    !email.contains(Constants.noReplyEmailDomain)
                else { return nil }
                return Contributor(name: name, email: email)
            }
            .filter { $0 != myself && seen.insert($0).inserted }
    }

    func commit(messageLines: [String], coAuthors: [Contributor]) -> (Bool, String?) {
        var fullMessage = messageLines.joined(separator: "\n")
        
        if !coAuthors.isEmpty {
            fullMessage += "\n"
            for contributor in coAuthors {
                fullMessage += "\nCo-authored-by: \(contributor.name) <\(contributor.email)>"
            }
        }

        return executeGitCommand(["commit", "-m", fullMessage])
    }
}
