import SwiftTUI
import Darwin

struct ContentView: View {
    @ObservedObject var service: ContributorService
    let repository: GitRepository
    let myself: Contributor?
    let commandName: String?
    let version: String

    @State var commitMessageLines: [String] = [""]
    @State var selectedContributors: Set<Contributor> = []

    var body: some View {
        VStack {
            CommitView(
                onSubmit: {
                    let coAuthors = Array(selectedContributors)
                    let success = repository.commit(messageLines: commitMessageLines, coAuthors: coAuthors)
                    if success {
                        exit(0)
                    }
                },
                lines: $commitMessageLines
            )
            ContributorsView(
                contributors: service.contributors,
                amountOfAnalyzedCommits: service.totalCommitsAnalyzed,
                analyzedAll: service.analyzedAll,
                onLoadMore: service.loadMore,
                selectedContributors: $selectedContributors
            )
            Spacer()
            FooterView(myself: myself, commandName: commandName, version: version)
        }
    }
}
