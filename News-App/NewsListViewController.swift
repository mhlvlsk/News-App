import UIKit
import Combine

class NewsListViewController: UIViewController {
    
    private var viewModel = NewsListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private let sortSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Date", "Popularity"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private var searchTextPublisher = PassthroughSubject<String, Never>()
    private var sortSelectionPublisher = PassthroughSubject<Int, Never>()
    
    private var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        tableView.publisher(for: \.contentOffset)
            .eraseToAnyPublisher()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        bindUI()
    }
    
    private func setupUI() {
        self.title = "News list"
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(sortSegmentedControl)
        
        view.backgroundColor = .white
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        sortSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            sortSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            sortSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: sortSegmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchBar.placeholder = "Search News"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.separatorStyle = .none
    }
    
    private func bindUI() {
        searchBar.textPublisher
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchTextPublisher.send(query)
            }
            .store(in: &cancellables)
        
        sortSegmentedControl.publisher(for: \.selectedSegmentIndex)
            .sink { [weak self] selectedIndex in
                self?.sortSelectionPublisher.send(selectedIndex)
            }
            .store(in: &cancellables)
        
        contentOffsetPublisher
            .sink { [weak self] contentOffset in
                guard let self = self else { return }
                let contentHeight = self.tableView.contentSize.height
                let offsetY = contentOffset.y
                let height = self.tableView.frame.size.height
                if offsetY > contentHeight - height - 50 {
                    self.viewModel.fetchNews()
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.$news
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] query in
                self?.viewModel.search(query: query)
            }
            .store(in: &cancellables)
        
        sortSelectionPublisher
            .sink { [weak self] selectedIndex in
                let criteria = selectedIndex == 0 ? "publishedAt" : "popularity"
                self?.viewModel.sortNews(by: criteria)
            }
            .store(in: &cancellables)
    }
    
    private func openNewsDetail(for indexPath: IndexPath) {
        let newsItem = viewModel.news[indexPath.row]
        
        let newsVC = NewsViewController()
        newsVC.newsItem = newsItem
        
        let navigationController = self.navigationController
        
        navigationController?.pushViewController(newsVC, animated: true)
    }
}

extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        let newsItem = viewModel.news[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: newsItem.date) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.textLabel?.text = "\(dateFormatter.string(from: date))\n\(newsItem.title)"
        } else {
            cell.textLabel?.text = "\(newsItem.date)\n\(newsItem.title)"
        }
        
        return cell
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openNewsDetail(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension UISearchBar {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self.searchTextField)
            .compactMap { ($0.object as? UISearchTextField)?.text }
            .eraseToAnyPublisher()
    }
}
