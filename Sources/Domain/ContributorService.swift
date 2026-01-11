import Foundation

class ContributorService: ObservableObject {
    private let repository: GitRepository
    private let pageSize: Int
    
    private var currentPage = 0
    @Published private(set) var contributors: [Contributor] = []
    private var seenContributors: Set<Contributor> = []
    
    var totalCommitsAnalyzed: Int { (currentPage + 1) * pageSize }
    var analyzedAll: Bool {
        guard let amountOfCommits = repository.amountOfCommits else { return false }
        return totalCommitsAnalyzed >= amountOfCommits
    }

    init(repository: GitRepository, pageSize: Int) {
        self.repository = repository
        self.pageSize = pageSize
        self.contributors = repository.getRecentContributors(amountOfCommits: pageSize, skipFirstCommits: 0)
        self.seenContributors = Set(contributors)
    }
    
    func loadMore() {
        currentPage += 1
        let newContributors = repository.getRecentContributors(
            amountOfCommits: pageSize,
            skipFirstCommits: currentPage * pageSize,
            excluding: seenContributors
        )
        contributors.append(contentsOf: newContributors)
        seenContributors.formUnion(newContributors)
    }
}
