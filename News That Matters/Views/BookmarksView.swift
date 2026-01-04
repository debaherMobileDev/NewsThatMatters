//
//  BookmarksView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if viewModel.articles.isEmpty {
                    emptyStateView
                } else {
                    articlesList
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article, viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadBookmarkedArticles()
            }
        }
    }
    
    private var articlesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.articles) { article in
                    ArticleCardView(article: article) {
                        selectedArticle = article
                    } onBookmark: {
                        viewModel.toggleBookmark(for: article)
                        // Refresh the list
                        viewModel.loadBookmarkedArticles()
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Bookmarks Yet")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
            
            Text("Bookmark articles to read them later")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    BookmarksView()
}

