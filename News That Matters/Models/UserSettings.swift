//
//  UserSettings.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @AppStorage("selectedTopics") private var selectedTopicsData: Data = Data()
    
    var selectedTopics: Set<String> {
        get {
            if let topics = try? JSONDecoder().decode(Set<String>.self, from: selectedTopicsData) {
                return topics
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                selectedTopicsData = data
            }
        }
    }
}

// Available news categories
enum NewsCategory: String, CaseIterable, Identifiable {
    case general = "general"
    case business = "business"
    case technology = "technology"
    case science = "science"
    case health = "health"
    case sports = "sports"
    case entertainment = "entertainment"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .general: return "newspaper"
        case .business: return "briefcase"
        case .technology: return "laptopcomputer"
        case .science: return "atom"
        case .health: return "heart"
        case .sports: return "sportscourt"
        case .entertainment: return "tv"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return .blue
        case .business: return .green
        case .technology: return .purple
        case .science: return .orange
        case .health: return .red
        case .sports: return .yellow
        case .entertainment: return .pink
        }
    }
}

