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
    
    
    
    //EkEvent
    @State private var showEventEdit: Bool = false
    @State private var completedAction: EKEventEditViewAction? = nil
    
    @State private var event: EKEvent? = nil
    
    //to i textfield z tym do usuniecia
    @State private var title: String = "123"
    
    private let eventStore = EKEventStore()
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Type title", text: $reminder.title)
                    .font(.headline)
                
                TextField("test", text: $title)
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
        
        .sheet(isPresented: $showEventEdit, onDismiss: {
            if completedAction == .saved {
                clearEvent()
            }
        }, content: {
            EventEditViewControllerRepresentable(
                store: eventStore,
                event: $event,
                isPresented: $showEventEdit,
                completedAction: $completedAction
            )
            .ignoresSafeArea(.all)
        })
        .toolbar {
            ToolbarItem {
                Button("add to calendar") {
                    createEvent()
                    showEventEdit = true
                }
            }
        }
    }
    private func createEvent() {
        let event = EKEvent(eventStore: self.eventStore)
        //tutaj co cchemy zeby sie wyswietlalo w okienku do edycji dodania do kalendarza
        event.title = self.reminder.handwrittenText ?? ""
        self.event = event
        
    }
    
    private func clearEvent() {
        self.event = nil
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



