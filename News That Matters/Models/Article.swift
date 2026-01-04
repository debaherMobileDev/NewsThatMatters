//
//  Article.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import CoreData

// MARK: - API Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [ArticleDTO]
}

struct ArticleDTO: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}

// MARK: - Core Data Entity
@objc(ArticleEntity)
public class ArticleEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var articleDescription: String?
    @NSManaged public var url: String
    @NSManaged public var imageURL: String?
    @NSManaged public var publishedAt: Date
    @NSManaged public var source: String
    @NSManaged public var author: String?
    @NSManaged public var content: String?
    @NSManaged public var category: String?
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var isSavedForOffline: Bool
    
    convenience init(context: NSManagedObjectContext, dto: ArticleDTO, category: String? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.title = dto.title
        self.articleDescription = dto.description
        self.url = dto.url
        self.imageURL = dto.urlToImage
        self.publishedAt = ISO8601DateFormatter().date(from: dto.publishedAt) ?? Date()
        self.source = dto.source.name
        self.author = dto.author
        self.content = dto.content
        self.category = category
        self.isBookmarked = false
        self.isSavedForOffline = false
    }
}

// MARK: - Display Model
struct Article: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let url: String
    let imageURL: String?
    let publishedAt: Date
    let source: String
    let author: String?
    let content: String?
    let category: String?
    var isBookmarked: Bool
    var isSavedForOffline: Bool
    
    init(from entity: ArticleEntity) {
        self.id = entity.id
        self.title = entity.title
        self.description = entity.articleDescription
        self.url = entity.url
        self.imageURL = entity.imageURL
        self.publishedAt = entity.publishedAt
        self.source = entity.source
        self.author = entity.author
        self.content = entity.content
        self.category = entity.category
        self.isBookmarked = entity.isBookmarked
        self.isSavedForOffline = entity.isSavedForOffline
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}

