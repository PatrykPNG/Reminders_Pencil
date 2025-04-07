//
//  DrawingView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 03/04/2025.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    
    @Bindable var reminder: Reminder
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        CanvasView(canvasView: $canvasView, onSaved: saveDrawing)
            .onAppear {
                loadDrawing()
            }
        //dla kazdego przypomnienia bedzie wyswietlac sie osobny przycisk
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("delete drawing", systemImage: "trash") {
//                        deleteDrawing()
//                    }
//                }
//            }
    }
    
//Drawing func
//    func deleteDrawing() {
//        canvasView.drawing = PKDrawing()
//    }
    
        //Wprowadz opozniony zapis zeby non stop sie nie zapisywalo, tylko np z opiznieniem 300 ms
    func saveDrawing() {
        let drawingData = canvasView.drawing.dataRepresentation()
        reminder.drawingData = drawingData
        try? modelContext.save()
        
        print("drawing saved")
    }
    
    func loadDrawing() {
        if let drawingData = reminder.drawingData {
            do {
                //Odtwarzanie PKDrawing z Data
                let drawing = try PKDrawing(data: drawingData)
                canvasView.drawing = drawing
            } catch {
                print("Error loading drawing: \(error)")
            }
        }
    }
}

#Preview {
    DrawingView(reminder: Reminder(title: "Laundry", order: 0))
        .modelContainer(for: Reminder.self)

}


