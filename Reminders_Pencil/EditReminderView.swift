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
