//
//  News_That_MattersApp.swift
//  News That Matters
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

@main
struct News_That_MattersApp: App {
    let persistenceService = PersistenceService.shared
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceService.viewContext)
                .environmentObject(userSettings)
        }
    }
}
