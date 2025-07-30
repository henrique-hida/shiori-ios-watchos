//
//  ShioriApp.swift
//  Shiori WatchKit Extension
//
//  Created by Henrique Hida on 29/07/25.
//

import SwiftUI

@main
struct ShioriApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
