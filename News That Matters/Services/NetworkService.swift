//
//  NetworkService.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    // NewsAPI.org API key - you'll need to replace this with your own key
    // Get free key at: https://newsapi.org/register
    private let apiKey = "YOUR_API_KEY_HERE"
    private let baseURL = "https://newsapi.org/v2"
    
    // Use mock data if API key is not set (for testing)
    private var useMockData: Bool {
        return apiKey == "YOUR_API_KEY_HERE" || apiKey.isEmpty
    }
    
    private init() {}
    
    func fetchTopHeadlines(category: String? = nil, country: String = "us") async throws -> [ArticleDTO] {
        // Return mock data if no API key
        if useMockData {
            print("⚠️ Using mock data. Add your NewsAPI key to NetworkService.swift")
            return getMockArticles(for: category)
        }
        
        var urlString = "\(baseURL)/top-headlines?country=\(country)&apiKey=\(apiKey)"
        
        if let category = category {
            urlString += "&category=\(category)"
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Check for specific error codes
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimitExceeded
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)
            return apiResponse.articles
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func fetchEverything(query: String, sortBy: String = "publishedAt") async throws -> [ArticleDTO] {
        // Return mock data if no API key
        if useMockData {
            print("⚠️ Using mock data. Add your NewsAPI key to NetworkService.swift")
            return getMockArticles(for: nil).filter { article in
                article.title.localizedCaseInsensitiveContains(query) ||
                (article.description?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/everything?q=\(encodedQuery)&sortBy=\(sortBy)&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Check for specific error codes
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimitExceeded
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)
            return apiResponse.articles
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    // MARK: - Mock Data for Testing
    private func getMockArticles(for category: String?) -> [ArticleDTO] {
        let now = ISO8601DateFormatter().string(from: Date())
        let hour1 = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
        let hour2 = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
        let hour3 = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-10800))
        
        let mockArticles = [
            ArticleDTO(
                source: Source(id: "techcrunch", name: "TechCrunch"),
                author: "Sarah Johnson",
                title: "Revolutionary AI Technology Transforms Healthcare Industry",
                description: "New artificial intelligence breakthrough promises to revolutionize patient care and medical diagnostics worldwide.",
                url: "https://example.com/article1",
                urlToImage: nil,
                publishedAt: now,
                content: "A groundbreaking development in artificial intelligence is set to transform the healthcare industry..."
            ),
            ArticleDTO(
                source: Source(id: "bbc-news", name: "BBC News"),
                author: "Michael Chen",
                title: "Global Climate Summit Reaches Historic Agreement",
                description: "World leaders commit to ambitious new carbon reduction targets in landmark environmental deal.",
                url: "https://example.com/article2",
                urlToImage: nil,
                publishedAt: hour1,
                content: "In a historic moment for global environmental policy, representatives from over 190 countries..."
            ),
            ArticleDTO(
                source: Source(id: "the-verge", name: "The Verge"),
                author: "Alex Rivera",
                title: "New Smartphone Features Push Boundaries of Innovation",
                description: "Latest flagship devices showcase cutting-edge technology and stunning design improvements.",
                url: "https://example.com/article3",
                urlToImage: nil,
                publishedAt: hour2,
                content: "The technology industry continues to amaze with innovative features in the latest smartphone releases..."
            ),
            ArticleDTO(
                source: Source(id: "espn", name: "ESPN"),
                author: "Jordan Thompson",
                title: "Underdog Team Secures Championship Victory",
                description: "Against all odds, the determined squad clinches an unexpected championship win.",
                url: "https://example.com/article4",
                urlToImage: nil,
                publishedAt: hour3,
                content: "In a thrilling finale that had fans on the edge of their seats, the underdog team emerged victorious..."
            ),
            ArticleDTO(
                source: Source(id: "bloomberg", name: "Bloomberg"),
                author: "Emily Watson",
                title: "Stock Markets Reach Record Highs Amid Economic Optimism",
                description: "Major indices surge as investors show renewed confidence in economic recovery.",
                url: "https://example.com/article5",
                urlToImage: nil,
                publishedAt: hour1,
                content: "Financial markets experienced significant gains today as economic indicators continue to show..."
            ),
            ArticleDTO(
                source: Source(id: "nature", name: "Nature"),
                author: "Dr. Robert Kim",
                title: "Scientists Discover Potential Cure for Rare Disease",
                description: "Breakthrough research offers hope to patients suffering from previously untreatable condition.",
                url: "https://example.com/article6",
                urlToImage: nil,
                publishedAt: hour2,
                content: "A team of researchers has made a significant breakthrough in the treatment of a rare genetic disorder..."
            )
        ]
        
        // Filter by category if needed
        if let category = category {
            // Simple filtering based on keywords
            return mockArticles.filter { article in
                switch category.lowercased() {
                case "technology":
                    return article.title.contains("AI") || article.title.contains("Smartphone") || article.title.contains("Technology")
                case "business":
                    return article.title.contains("Stock") || article.title.contains("Economic")
                case "science":
                    return article.title.contains("Scientists") || article.title.contains("Research")
                case "health":
                    return article.title.contains("Healthcare") || article.title.contains("Disease")
                case "sports":
                    return article.title.contains("Championship") || article.title.contains("Team")
                default:
                    return true
                }
            }
        }
        
        return mockArticles
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case serverError(Int)
    case decodingError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Invalid API key. Please check your NewsAPI.org credentials."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error (code \(code)). Please try again later."
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        }
    }
}

