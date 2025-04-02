//
//  EditReminderView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 02/04/2025.
//

import SwiftUI

struct EditReminderView: View {
    @Bindable var reminder: Reminder
    
    var body: some View {
        Form {
            Section("Title") {
                Text(reminder.title)
                    .font(.headline)
            }
            Section("Position") {
                Text(String(reminder.order))
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    EditReminderView(reminder: Reminder(title: "Test", order: 1))
        .modelContainer(for: Reminder.self)
}
