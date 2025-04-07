//
//  CanvasView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 03/04/2025.
//

import SwiftUI
import PencilKit

struct CanvasView {
    @Binding var canvasView: PKCanvasView
    let onSaved: () -> Void
    @State var toolPicker = PKToolPicker()
}

private extension CanvasView {
    func showToolPicker() {
        //1 widoczny wtedy kiedy canvas view jest aktywny
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        //2 canwas view informawane o zmianach dla toolpickera
        toolPicker.addObserver(canvasView)
        
        //3 prosba o zrobienioe canvas view first responder w celu azrobienia toolpicekra widocznym.
        canvasView.becomeFirstResponder()
    }
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
//        canvasView.tool = PKInkingTool(.pencil, color: .black, width: 10)
//        canvasView.drawingPolicy = .pencilOnly
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        //przypisuje koordynator, ktory zdefiniowalem jako delegata canvasView.
        canvasView.delegate = context.coordinator
        showToolPicker()
        return canvasView
    }
    
    //Reaguje na zmiany w swiftui view
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Jesli tutaj nie ma toolpickera to po wejsciu w navLink i powrocie toolpicker znika, nie jest dostepny
        showToolPicker()
    }
    
    func makeCoordinator() -> Coordinator {
        //Tworze koordynator i zwracam go dla widoku swiftUI, swiftUI wywoluje ta funkcje przed makeUIView, ustawia canvasView aby upewnic sie, ze koordynator jest dostepny kiedy tworze i konfiguruje canvasView.
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
}

//Koordynator do komunikacji pomiedzy swiftUi a canvasView, custommowy init ustawia binding dla canvas view  i {} do wywolania aktualizacji rysunku.
class Coordinator: NSObject {
    var canvasView: Binding<PKCanvasView>
    let onSaved: () -> Void
    
    init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
        self.canvasView = canvasView
        self.onSaved = onSaved
    }
}
//moze tutaj cos z pickerem?
//Reaguje na aktualizacje w rysunku. Aktywuje sie kiedy nastaja jakies zmiany w rysunkju.
extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
            onSaved()
        }
    }
}
