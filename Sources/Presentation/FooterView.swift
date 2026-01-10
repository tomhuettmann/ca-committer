import SwiftTUI

struct FooterView: View {
    let myself: Contributor?
    let commandName: String?
    let version: String

    var body: some View {
        HStack(alignment: .bottom) {
            VStack {
                Text("Author")
                if let myself {
                    Text("\(myself.name) (\(myself.email))")
                } else {
                    Text("Unknown")
                }
            }
            Spacer()
            if let commandName {
                Text(commandName)
            }
            Text(version)
        }
    }
}
