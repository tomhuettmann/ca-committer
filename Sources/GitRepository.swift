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

    func getRecentContributors(amountOfCommits: Int, skipFirstCommits: Int = 0) -> [Contributor] {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "log", "--format=%an|%ae", "--skip", "\(skipFirstCommits)", "-n", "\(amountOfCommits)"]

        try? process.run()
        process.waitUntilExit()

        guard
            process.terminationStatus == 0,
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        else { return [] }

        let myself = getMyself()
        var seen = Set<String>()
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
                    !email.contains("noreply.github.com"),
                    !(myself?.name.lowercased() == name.lowercased() && myself?.email.lowercased() == email.lowercased())
                else { return nil }
                return Contributor(name: name, email: email)
            }
            .filter { seen.insert("\($0.name.lowercased()),\($0.email.lowercased())").inserted }
    }

    func getMyself() -> Contributor? {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "config", "--get-regexp", "^user\\.(name|email)$"]

        try? process.run()
        process.waitUntilExit()

        guard
            process.terminationStatus == 0,
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        else { return nil }

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
}
