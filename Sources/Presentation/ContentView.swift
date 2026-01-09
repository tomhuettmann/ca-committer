import SwiftTUI

struct ContentView: View {
    @State var contributors: [Contributor]
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
                selectedContributors: $selectedContributors
            )
        }
    }
}
