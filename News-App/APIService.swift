import Foundation
import Combine

class APIService {
    private let apiKey = "7193e5b82ad44d2b8e26b90721ab4b97"
    private let baseURL = "https://newsapi.org/v2/everything"
    
    func fetchNews(query: String, page: Int, pageSize: Int = 20) -> AnyPublisher<[News], Error> {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        let url = components.url!
        print("Request URL: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(jsonString)")
                }
                return data
            }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .map { $0.articles }
            .eraseToAnyPublisher()
    }
}
