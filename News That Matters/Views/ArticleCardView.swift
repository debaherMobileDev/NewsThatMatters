//
//  ArticleCardView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let onTap: () -> Void
    let onBookmark: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                if let imageURL = article.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            placeholderImage
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(article.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    // Description
                    if let description = article.description {
                        Text(description)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    
                    // Metadata
                    HStack {
                        // Source
                        Label(article.source, systemImage: "building.2")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        // Time
                        Text(article.formattedDate)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Category tag and bookmark
                    HStack {
                        if let category = article.category {
                            Text(category.uppercased())
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primaryBackground)
                                .cornerRadius(6)
                        }
                        
                        Spacer()
                        
                        Button(action: onBookmark) {
                            Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(article.isBookmarked ? .accentButton : .textSecondary)
                                .font(.system(size: 18))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.secondaryBackground, Color.tertiaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            )
            .cornerRadius(12)
    }
}

#Preview {
    ArticleCardView(
        article: Article(
            from: ArticleEntity(
                context: PersistenceService.shared.viewContext,
                dto: ArticleDTO(
                    source: Source(id: nil, name: "TechCrunch"),
                    author: "John Doe",
                    title: "Breaking: New Technology Announced",
                    description: "This is a sample description for the article that will be truncated at two lines",
                    url: "https://example.com",
                    urlToImage: nil,
                    publishedAt: ISO8601DateFormatter().string(from: Date()),
                    content: "Full content here"
                ),
                category: "technology"
            )
        ),
        onTap: {},
        onBookmark: {}
    )
    .padding()
}

