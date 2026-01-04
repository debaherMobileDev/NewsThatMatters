//
//  NewsFeedViewModel.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class NewsFeedViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: NewsCategory?
    @Published var searchQuery = ""
    @Published var showingSearch = false
    
    private let networkService = NetworkService.shared
    private let persistenceService = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.performSearch(query: query)
                } else {
                    self?.loadLocalArticles()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadArticles(for category: NewsCategory? = nil, forceRefresh: Bool = false) {
        selectedCategory = category
        
        if forceRefresh {
            Task {
                await fetchRemoteArticles(category: category)
            }
        } else {
            loadLocalArticles()
            
            // Refresh in background if we have no articles or they're old
            if articles.isEmpty || shouldRefresh() {
                Task {
                    await fetchRemoteArticles(category: category)
                }
            }
        }
    }
    
    private func loadLocalArticles() {
        if let category = selectedCategory {
            articles = persistenceService.fetchArticles(category: category.rawValue)
        } else {
            articles = persistenceService.fetchArticles()
        }
    }
    
    private func fetchRemoteArticles(category: NewsCategory?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedArticles = try await networkService.fetchTopHeadlines(
                category: category?.rawValue
            )
            
            // Save to Core Data
            persistenceService.saveArticles(fetchedArticles, category: category?.rawValue)
            
            // Reload from Core Data to get proper Article objects
            loadLocalArticles()
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            
            // Still try to load cached articles on error
            loadLocalArticles()
        }
    }
    
    private func shouldRefresh() -> Bool {
        guard let mostRecent = articles.first?.publishedAt else { return true }
        let hoursSinceUpdate = Date().timeIntervalSince(mostRecent) / 3600
        return hoursSinceUpdate > 1 // Refresh if older than 1 hour
    }
    
    func performSearch(query: String) {
        if query.isEmpty {
            loadLocalArticles()
            return
        }
        
        // First search locally
        articles = persistenceService.searchArticles(query: query)
        
        // Then search remotely
        Task {
            isLoading = true
            
            do {
                let fetchedArticles = try await networkService.fetchEverything(query: query)
                persistenceService.saveArticles(fetchedArticles)
                
                // Reload search results
                articles = persistenceService.searchArticles(query: query)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func toggleBookmark(for article: Article) {
        persistenceService.toggleBookmark(for: article.id)
        HapticFeedback.light.generate()
        
        // Update the article in the list
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index].isBookmarked.toggle()
        }
    }
    
    func toggleOfflineStatus(for article: Article) {
        persistenceService.toggleOfflineStatus(for: article.id)
        HapticFeedback.light.generate()
        
        // Update the article in the list
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index].isSavedForOffline.toggle()
        }
    }
    
    func loadBookmarkedArticles() {
        articles = persistenceService.fetchArticles(bookmarkedOnly: true)
    }
    
    func cleanupOldArticles() {
        persistenceService.deleteOldArticles(olderThan: 30)
    }
    
    func refresh() async {
        await fetchRemoteArticles(category: selectedCategory)
    }
}

