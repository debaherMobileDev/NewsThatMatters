//
//  ArticleDetailView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var viewModel: NewsFeedViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header image
                    if let imageURL = article.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                placeholderImage
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .clipped()
                            case .failure:
                                placeholderImage
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .frame(height: 250)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Category and bookmark
                        HStack {
                            if let category = article.category {
                                Text(category.uppercased())
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryBackground)
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        
                        // Title
                        Text(article.title)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        // Metadata
                        HStack(spacing: 12) {
                            Label(article.source, systemImage: "building.2")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.textSecondary)
                            
                            if let author = article.author {
                                Label(author, systemImage: "person")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Text(article.publishedAt.timeAgoDisplay())
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.textSecondary)
                        
                        Divider()
                        
                        // Description
                        if let description = article.description {
                            Text(description)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Content
                        if let content = article.content {
                            Text(content)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.toggleBookmark(for: article)
                        }) {
                            Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(article.isBookmarked ? .accentButton : .textSecondary)
                        }
                        
                        Button(action: {
                            shareArticle()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.secondaryBackground, Color.tertiaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 250)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            )
    }
    
    private func shareArticle() {
        guard let url = URL(string: article.url) else { return }
        let activityVC = UIActivityViewController(
            activityItems: [article.title, url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

