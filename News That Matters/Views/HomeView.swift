//
//  HomeView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedArticle: Article?
    @State private var showingCategoryPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category selector
                    categoryScrollView
                    
                    // Articles list
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        loadingView
                    } else if viewModel.articles.isEmpty {
                        emptyStateView
                    } else {
                        articlesList
                    }
                }
            }
            .navigationTitle("News That Matters")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: "Search news...")
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadArticles()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All News button
                CategoryChip(
                    category: nil,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.loadArticles(for: nil, forceRefresh: true)
                }
                
                // Category buttons
                ForEach(NewsCategory.allCases) { category in
                    if userSettings.selectedTopics.isEmpty || userSettings.selectedTopics.contains(category.rawValue) {
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.loadArticles(for: category, forceRefresh: true)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.cardBackground)
    }
    
    private var articlesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.articles) { article in
                    ArticleCardView(article: article) {
                        selectedArticle = article
                    } onBookmark: {
                        viewModel.toggleBookmark(for: article)
                    }
                }
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading news...")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No articles found")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
            
            Text("Pull to refresh or try a different category")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: NewsCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                    Text(category.displayName)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                    Text("All News")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryBackground : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primaryBackground, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserSettings())
}

