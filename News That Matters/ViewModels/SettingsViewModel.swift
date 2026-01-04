//
//  SettingsViewModel.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func toggleTopic(_ topic: NewsCategory) {
        var topics = userSettings.selectedTopics
        if topics.contains(topic.rawValue) {
            topics.remove(topic.rawValue)
        } else {
            topics.insert(topic.rawValue)
        }
        userSettings.selectedTopics = topics
        HapticFeedback.light.generate()
    }
    
    func isTopicSelected(_ topic: NewsCategory) -> Bool {
        return userSettings.selectedTopics.contains(topic.rawValue)
    }
    
    func clearCache() {
        ImageCache.shared.clear()
        HapticFeedback.success.generate()
    }
    
    func resetOnboarding() {
        userSettings.hasCompletedOnboarding = false
    }
}

