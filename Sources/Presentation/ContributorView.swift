import SwiftTUI

struct ContributorView: View {
    let contributor: Contributor
    let selected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(selected ? "[X]" : "[ ]") { onToggle() }
            Text("\(contributor.name) (\(contributor.email))")
            Spacer()
        }
    }
}
