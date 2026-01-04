//
//  ContentView.swift
//  News That Matters
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !userSettings.hasCompletedOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }
                .tag(2)
            
            SettingsView(userSettings: userSettings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(.primaryBackground)
    }
}

// MARK: - Search View
struct SearchView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.searchQuery.isEmpty && viewModel.articles.isEmpty {
                    emptySearchView
                } else if viewModel.isLoading && viewModel.articles.isEmpty {
                    loadingView
                } else if viewModel.articles.isEmpty {
                    noResultsView
                } else {
                    articlesList
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: "Search news...")
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article, viewModel: viewModel)
            }
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("Search News")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
            
            Text("Search for any topic or keyword")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Results Found")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
            
            Text("Try searching for something else")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .padding()
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
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
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
        .environment(\.managedObjectContext, PersistenceService.shared.viewContext)
}
