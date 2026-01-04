//
//  PersistenceService.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import CoreData

class PersistenceService {
    static let shared = PersistenceService()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "NewsDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Article Operations
    func saveArticles(_ dtos: [ArticleDTO], category: String? = nil) {
        let context = container.viewContext
        
        for dto in dtos {
            // Check if article already exists
            let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "url == %@", dto.url)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    _ = ArticleEntity(context: context, dto: dto, category: category)
                }
            } catch {
                print("Error checking for existing article: \(error)")
            }
        }
        
        save()
    }
    
    func fetchArticles(category: String? = nil, bookmarkedOnly: Bool = false) -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ArticleEntity.publishedAt, ascending: false)]
        
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if bookmarkedOnly {
            predicates.append(NSPredicate(format: "isBookmarked == YES"))
        }
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            let entities = try viewContext.fetch(fetchRequest)
            return entities.map { Article(from: $0) }
        } catch {
            print("Error fetching articles: \(error)")
            return []
        }
    }
    
    func toggleBookmark(for articleId: UUID) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let entity = results.first {
                entity.isBookmarked.toggle()
                save()
            }
        } catch {
            print("Error toggling bookmark: \(error)")
        }
    }
    
    func toggleOfflineStatus(for articleId: UUID) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let entity = results.first {
                entity.isSavedForOffline.toggle()
                save()
            }
        } catch {
            print("Error toggling offline status: \(error)")
        }
    }
    
    func searchArticles(query: String) -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR articleDescription CONTAINS[cd] %@", query, query)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ArticleEntity.publishedAt, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(fetchRequest)
            return entities.map { Article(from: $0) }
        } catch {
            print("Error searching articles: \(error)")
            return []
        }
    }
    
    func deleteOldArticles(olderThan days: Int = 30) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        let date = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        fetchRequest.predicate = NSPredicate(format: "publishedAt < %@ AND isBookmarked == NO AND isSavedForOffline == NO", date as NSDate)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            for entity in results {
                viewContext.delete(entity)
            }
            save()
        } catch {
            print("Error deleting old articles: \(error)")
        }
    }
}

// Extension for NSFetchRequest
extension ArticleEntity {
    static func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }
}

