import SwiftTUI

struct ContentView: View {
    @ObservedObject var service: ContributorService
    let myself: Contributor?
    let commandName: String?
    let version: String

    @State var commitMessageLines: [String] = [""]
    @State var selectedContributors: Set<Contributor> = []

    var body: some View {
        VStack {
            CommitView(
                onSubmit: {
                    print()
                    print("message: \(commitMessageLines)")
                    print("contributors: \(selectedContributors)")
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
