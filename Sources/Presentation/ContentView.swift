import Darwin
import SwiftTUI

struct ContentView: View {
    @ObservedObject var service: ContributorService
    let repository: GitRepository
    let myself: Contributor?
    let commandName: String?
    let version: String

    @State var commitMessageLines: [String] = [""]
    @State var selectedContributors: Set<Contributor> = []
    @State var commitSuccessful: Bool?
    @State var commitErrorMessage: String?

    var body: some View {
        VStack {
            if commitSuccessful == false {
                CommitErrorView(output: commitErrorMessage)
            }
            CommitView(
                onSubmit: {
                    let (success, message) = repository.commit(messageLines: commitMessageLines, coAuthors: Array(selectedContributors))
                    if success {
                        exit(0)
                    } else {
                        commitSuccessful = false
                        commitErrorMessage = message
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
