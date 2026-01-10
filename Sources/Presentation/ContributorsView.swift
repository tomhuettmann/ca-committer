import SwiftTUI

struct ContributorsView: View {
    let contributors: [Contributor]
    let amountOfAnalyzedCommits: Int
    let onLoadMore: () -> Void

    @Binding var selectedContributors: Set<Contributor>

    var body: some View {
        VStack {
            HStack {
                Text("Recent Contributors (analyzed last \(amountOfAnalyzedCommits) commits)")
                Spacer()
            }
            VStack(alignment: .leading) {
                ForEach(contributors, id: \.self) { contributor in
                    ContributorView(
                        contributor: contributor,
                        selected: selectedContributors.contains(contributor),
                        onToggle: {
                            if selectedContributors.contains(contributor) {
                                selectedContributors.remove(contributor)
                            } else {
                                selectedContributors.insert(contributor)
                            }
                        }
                    )
                }
                Button("...") {
                    onLoadMore()
                }
            }
            .border()
        }
    }
}
