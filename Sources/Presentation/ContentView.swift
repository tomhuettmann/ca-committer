import SwiftTUI

struct ContentView: View {
    @State var contributors: [Contributor]
    @State var amountOfAnalyzedCommits: Int
    let myself: Contributor?
    let commandName: String?
    let version: String
    let onLoadMoreContributors: () -> ([Contributor], Int)

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
                contributors: contributors,
                amountOfAnalyzedCommits: amountOfAnalyzedCommits,
                onLoadMore: {
                    let (newContributors, totalAnalyzed) = onLoadMoreContributors()
                    newContributors
                        .filter { !contributors.contains($0) }
                        .forEach { contributors.append($0) }
                    amountOfAnalyzedCommits = totalAnalyzed
                },
                selectedContributors: $selectedContributors
            )
            Spacer()
            FooterView(myself: myself, commandName: commandName, version: version)
        }
    }
}
