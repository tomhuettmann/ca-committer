import Foundation

struct Contributor: Hashable {
    let name: String
    let email: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
        hasher.combine(email.lowercased())
    }
    
    static func == (lhs: Contributor, rhs: Contributor) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased() &&
        lhs.email.lowercased() == rhs.email.lowercased()
    }
}
