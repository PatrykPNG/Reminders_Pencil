//
//  CanvasView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 03/04/2025.
//

//Problem z AtributeGraph: cycle, wynikal z powodu tool pickera w updateUi view, trzeba bylo go zguardowac

//Rozwiazanie problemu z rysowaniem to zrobienie wspolnego pickera dla wszystkich CanvasView, sposobem na rozwiazanie okazala sie metoda singleton

//Zastanow sie nad zastosowaniem @Binding
import SwiftUI
import PencilKit
import Vision


struct CanvasView {
    @Binding var canvasView: PKCanvasView
    let onSaved: () -> Void
}

private extension CanvasView {
    func configureToolPicker(for canvasView: PKCanvasView) {
        let toolPicker = ToolManager.shared.toolPicker
        
        DispatchQueue.main.async {
            //1 widoczny wtedy kiedy canvas view jest aktywny
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            //2 canwas view informawane o zmianach dla toolpickera
            toolPicker.addObserver(canvasView)
            //3 prosba o zrobienioe canvas view first responder w celu azrobienia toolpicekra widocznym.
            canvasView.becomeFirstResponder()
        }
    }
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
//        canvasView.tool = PKInkingTool(.pencil, color: .black, width: 10)
//        canvasView.drawingPolicy = .pencilOnly
//        canvasView.backgroundColor = UIColor.systemGray
        canvasView.isOpaque = true
        //przypisuje koordynator, ktory zdefiniowalem jako delegata canvasView.
        canvasView.delegate = context.coordinator
        
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        
        configureToolPicker(for: canvasView)
        return canvasView
    }
    
    //Reaguje na zmiany w swiftui view
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        //po wejsciu w navLink i powrocie toolpicker znika, nie jest dostepny, wiec trzeba zrobic nowego, jesli nie ma poprzedniego.
        if !ToolManager.shared.toolPicker.isVisible {
            configureToolPicker(for: uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        //Tworze koordynator i zwracam go dla widoku swiftUI, swiftUI wywoluje ta funkcje przed makeUIView, ustawia canvasView aby upewnic sie, ze koordynator jest dostepny kiedy tworze i konfiguruje canvasView.
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
}

//Koordynator do komunikacji pomiedzy swiftUi a canvasView, custommowy init ustawia binding dla canvas view  i {} do wywolania aktualizacji rysunku.
class Coordinator: NSObject {
    @Binding var canvasView: PKCanvasView
    let onSaved: () -> Void
    
    init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
        self._canvasView = canvasView
        self.onSaved = onSaved
    }
}

//Reaguje na aktualizacje w rysunku. Aktywuje sie kiedy nastaja jakies zmiany w rysunkju.
extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        //guard patent na zapobieganie "pustym zmiana"
        guard !canvasView.drawing.bounds.isEmpty else { return }
        onSaved()
    }
}


//PKDrawing na UIImage
extension PKDrawing {
    func toImage(size: CGSize) -> UIImage {
        let drawingImage = self.image(from: CGRect(origin: .zero, size: size), scale: 1.0)
        return drawingImage
    }
}

