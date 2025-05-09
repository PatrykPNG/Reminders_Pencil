//
//  EditReminderView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 02/04/2025.
//

import SwiftUI
import EventKit
import EventKitUI

struct EditReminderView: View {
    @Bindable var reminder: Reminder

    
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Type title", text: $reminder.title)
                    .font(.headline)
                
            }
            Section("Position") {
                Text(String(reminder.order))
                    .font(.subheadline)
            }
            Section("Drawing preview") {
                if let previewImage = reminder.getDrawingPreviewImage() {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Text("No preview image")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Drawing text") {
                if let handwrittenText = reminder.handwrittenText, !handwrittenText.isEmpty {
                    Text("Recognized text:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(handwrittenText)
                        .font(.body)
                } else {
                    Text("Recognized text is unvalible")
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("add to reminders") {
                    let reminderText = (reminder.handwrittenText?.isEmpty == false)
                    ? reminder.handwrittenText! : "Text Recognition left handWritten value empty"
                    
                    addToSystemReminders(title: reminderText) { result in
                        switch result {
                        case .success:
                            print("reminder added to reminders")
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    func addToSystemReminders(title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToReminders() { granted, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard granted else {
                print("no acces to reminders")
                return
            }
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = title
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
            do {
                try eventStore.save(reminder, commit: true)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

#Preview {
    EditReminderView(reminder: Reminder(title: "Test", order: 1))
        .modelContainer(for: Reminder.self)
}

extension Reminder {
    func getDrawingPreviewImage() -> UIImage? {
        guard let previewData = drawingPreview else { return nil }
        return UIImage(data: previewData)
    }
}



