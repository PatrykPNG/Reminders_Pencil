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
    
    @State private var searchText = ""
    
    
    
    var body: some View {
        NavigationSplitView {
            Text("Tutaj Listy typu taski domowe, praca itd. Tagi i inne")
                .searchable(text: $searchText, prompt: "Search for a reminder")
                .navigationTitle("tescik")
        } detail: {
            ReminderView()
        }
    }
}

#Preview {
    ContentView()
}
