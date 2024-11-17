import Foundation
import Combine

class NewsListViewModel {
    private var apiService = APIService()
    
    @Published var news: [News] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var searchQuery = ""
    private var page = 1
    private var sortBy: String = "publishedAt"
    
    private var searchSubject = PassthroughSubject<String, Never>()
    
    init() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchQuery = query
                self?.page = 1
                self?.fetchNews()
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        searchSubject.send(query)
    }
    
    func fetchNews() {
        guard !searchQuery.isEmpty, !isLoading else { return }
        
        isLoading = true
        apiService.fetchNews(query: searchQuery, page: page)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] news in
                let filteredNews = news.filter { $0.title != "[Removed]" }
                self?.news = self?.page == 1 ? filteredNews : (self?.news ?? []) + filteredNews
                self?.sortNews(by: self?.sortBy ?? "publishedAt")
                self?.page += 1
            })
            .store(in: &cancellables)
    }
    
    func sortNews(by criteria: String) {
        sortBy = criteria
        news.sort { (lhs, rhs) in
            if sortBy == "popularity" {
                return lhs.title > rhs.title    //Sort by title, NewsAPI has no popularity info
            } else {
                return lhs.date > rhs.date
            }
        }
    }
}
