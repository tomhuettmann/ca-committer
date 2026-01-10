import SwiftTUI

struct ContributorsView: View {
    let contributors: [Contributor]

    @Binding var selectedContributors: Set<Contributor>

    var body: some View {
        VStack {
            HStack {
                Text("Recent Contributors")
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
            }
            .border()
        }
    }
}
