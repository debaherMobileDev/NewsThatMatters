//
//  SettingsView.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @StateObject private var viewModel: SettingsViewModel
    
    init(userSettings: UserSettings) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userSettings: userSettings))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Preferences Section
                Section(header: Text("Preferences")) {
                    // Topics
                    NavigationLink(destination: TopicSelectionView()) {
                        Label("News Topics", systemImage: "list.bullet")
                    }
                    
                    // Language
                    Picker("Language", selection: $userSettings.selectedLanguage) {
                        Text("English").tag("en")
                        Text("Español").tag("es")
                        Text("Français").tag("fr")
                        Text("Deutsch").tag("de")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Data & Storage Section
                Section(header: Text("Data & Storage")) {
                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        Label("Clear Image Cache", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.textSecondary)
                    }
                    
                    Link(destination: URL(string: "https://newsapi.org")!) {
                        Label("Powered by NewsAPI.org", systemImage: "link")
                    }
                }
                
                // Developer Options (hidden)
                #if DEBUG
                Section(header: Text("Developer")) {
                    Button(action: {
                        viewModel.resetOnboarding()
                    }) {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Topic Selection View
struct TopicSelectionView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(NewsCategory.allCases) { category in
                Button(action: {
                    toggleTopic(category)
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .frame(width: 30)
                        
                        Text(category.displayName)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        if isSelected(category) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.primaryButton)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Topics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func isSelected(_ category: NewsCategory) -> Bool {
        return userSettings.selectedTopics.contains(category.rawValue)
    }
    
    private func toggleTopic(_ category: NewsCategory) {
        var topics = userSettings.selectedTopics
        if topics.contains(category.rawValue) {
            topics.remove(category.rawValue)
        } else {
            topics.insert(category.rawValue)
        }
        userSettings.selectedTopics = topics
        HapticFeedback.light.generate()
    }
}

#Preview {
    SettingsView(userSettings: UserSettings())
        .environmentObject(UserSettings())
}

