//
//  PinetumApp.swift
//  Pinetum
//
//  Created by David Murphy on 1/24/23.
//

import SwiftUI

@main
struct PinetumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
