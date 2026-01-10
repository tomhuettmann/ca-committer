import SwiftTUI

struct CommitView: View {
    let onSubmit: () -> Void

    @Binding var lines: [String]

    var body: some View {
        VStack {
            title
            textFieldArea
            buttonArea
        }
    }

    private var title: some View {
        HStack {
            Text("Commit Message (Hit Enter to save)")
            Spacer()
        }
    }

    private var textFieldArea: some View {
        ForEach(0 ..< lines.count, id: \.self) { index in
            HStack {
                HStack {
                    if lines[index].isEmpty {
                        Text("> ")
                            .foregroundColor(.blue)
                        TextField(placeholder: " ") {
                            lines[index] = $0
                        }
                    } else {
                        Text("  ")
                        Text(lines[index])
                    }
                    Spacer()
                }
                .border(lines[index].isEmpty ? .blue : .default)
            }
        }
    }

    private var buttonArea: some View {
        HStack {
            Button("Commit") {
                guard lines.first?.isEmpty == false else { return }
                onSubmit()
            }
            .foregroundColor(lines.first?.isEmpty == true ? .gray : .green)
            .padding(.horizontal, 2)
            .border(lines.first?.isEmpty == true ? .gray : .green)

            if lines.first?.isEmpty == false {
                Button("Add Line") { lines.append("") }
                    .padding(.horizontal, 2)
                    .border()
                Spacer()
                Button("Reset") { lines = [""] }
                    .foregroundColor(.red)
                    .padding(.horizontal, 2)
                    .border(.red)
            }
        }
    }
}
