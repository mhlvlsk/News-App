import UIKit

class NewsViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    
    var newsItem: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }
    
    private func setupUI() {
        self.title = "News"
        view.backgroundColor = .white
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .darkGray
        
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, authorLabel, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureView() {
        guard let newsItem = newsItem else { return }
        
        titleLabel.text = newsItem.title
        authorLabel.text = "Author: \(newsItem.author ?? "Unknown")"
        contentLabel.text = newsItem.content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: newsItem.date) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = newsItem.date
        }
    }
}
