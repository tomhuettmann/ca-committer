import SwiftTUI

struct CommitErrorView: View {
    let output: String?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Error occured while committing. Try again or exit with Ctrl+C")
                    .foregroundColor(.red)
                Spacer()
            }
            if let output {
                VStack {
                    ForEach(output.components(separatedBy: .newlines), id: \.self) { line in
                        Text(line)
                    }
                }
            }
        }
        .border()
    }
}
