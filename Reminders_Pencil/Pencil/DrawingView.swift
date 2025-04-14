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
    }
    

    
        //Wprowadz opozniony zapis zeby non stop sie nie zapisywalo, tylko np z opiznieniem 300 ms
    func saveDrawing() {
        //jesli jest ten sam co wczesniej return, jesli nie jest taki jak reminder.drawingData, to wykonaj
        guard canvasView.drawing.dataRepresentation() != reminder.drawingData else { return }
        
        //zzapis danych rysunku
        reminder.drawingData = canvasView.drawing.dataRepresentation()
        
        //podglad obrazu
        let drawingPreview = canvasView.drawing.toImage(size: canvasView.bounds.size)
        reminder.drawingPreview = drawingPreview.pngData()
        
        //rozpoznawanie tekstu z rysunku
        canvasView.drawing.recognizeText { recognizedText in
            //update tekstu na glownym watku
            DispatchQueue.main.async {
                self.reminder.handwrittenText = recognizedText
                
                //opozniony zapis do bazy swiftData
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    do {
                        try self.modelContext.save()
                        print("Reminder saved, with text: \(recognizedText ?? "Unknown to recognize text")")
                    } catch {
                        print("Error ocured when saving to swiftData: \(error)")
                    }
                }
            }
        }
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


