//
//  dnd_appApp.swift
//  dnd_app
//
//  Created by Alexander Aferenok on 04.09.2025.
//

import SwiftUI

@main
struct dnd_appApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
    }
}
