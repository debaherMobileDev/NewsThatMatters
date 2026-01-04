//
//  OnboardingView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentPage = 0
    @State private var selectedTopics: Set<String> = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primaryBackground.opacity(0.9),
                    Color.secondaryBackground.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    topicSelectionPage.tag(1)
                    finalPage.tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryBackground)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Image(systemName: "newspaper.fill")
                .font(.system(size: 100))
                .foregroundColor(.white)
            
            Text("News That Matters")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Stay informed with personalized news curated just for you")
                .font(.system(.title3, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var topicSelectionPage: some View {
        VStack(spacing: 30) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Text("Choose Your Interests")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Select topics that matter to you")
                .font(.system(.title3, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // Topic grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(NewsCategory.allCases) { category in
                    TopicButton(
                        category: category,
                        isSelected: selectedTopics.contains(category.rawValue)
                    ) {
                        toggleTopic(category)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var finalPage: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.primaryButton)
            
            Text("You're All Set!")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Start exploring news that truly matters to you")
                .font(.system(.title3, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "sparkles", text: "Personalized news feed")
                FeatureRow(icon: "arrow.down.circle", text: "Offline reading support")
                FeatureRow(icon: "bookmark", text: "Save articles for later")
                FeatureRow(icon: "magnifyingglass", text: "Search any topic")
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func toggleTopic(_ category: NewsCategory) {
        if selectedTopics.contains(category.rawValue) {
            selectedTopics.remove(category.rawValue)
        } else {
            selectedTopics.insert(category.rawValue)
        }
        HapticFeedback.light.generate()
    }
    
    private func completeOnboarding() {
        userSettings.selectedTopics = selectedTopics.isEmpty ? Set(NewsCategory.allCases.map { $0.rawValue }) : selectedTopics
        userSettings.hasCompletedOnboarding = true
        HapticFeedback.success.generate()
    }
}

// MARK: - Supporting Views
struct TopicButton: View {
    let category: NewsCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                
                Text(category.displayName)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .primaryBackground : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryButton)
                .frame(width: 30)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserSettings())
}

