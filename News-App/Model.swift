import Foundation

struct NewsResponse: Decodable {
    let articles: [News]
}

struct News: Decodable, Identifiable, Hashable {
    let id = UUID()
    let author: String?
    let title: String
    let url: String
    let date: String
    let content: String

    enum CodingKeys: String, CodingKey {
        case date = "publishedAt"
        case title
        case url
        case author
        case content
    }
}
