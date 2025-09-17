//
//  dnd_appApp.swift
//  dnd_app
//
//  Created by Alexander Aferenok on 04.09.2025.
//

import SwiftUI

@main
struct dnd_appApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var dataService = DataService.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settingsManager)
                .environmentObject(dataService)
                .preferredColorScheme(settingsManager.settings.selectedTheme.colorScheme)
        }
    }
}
