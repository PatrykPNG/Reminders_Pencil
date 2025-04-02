//
//  Reminders_PencilApp.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 01/04/2025.
//

import SwiftUI
import SwiftData

@main
struct Reminders_PencilApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Reminder.self)
    }
}
