//
//  ContentView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 01/04/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ReminderView()
                .navigationTitle("Reminders")
        }
    }
}

#Preview {
    ContentView()
}
