//
//  CanvasView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 03/04/2025.
//

//Problem z AtributeGraph: cycle, wynikal z powodu tool pickera w updateUi view, trzeba bylo go zguardowac

//Zastanow sie nad zastosowaniem @Binding
import SwiftUI
import PencilKit
import Vision

struct CanvasView {
    @Binding var canvasView: PKCanvasView
    let onSaved: () -> Void
    @State var toolPicker = PKToolPicker()
}

private extension CanvasView {
    func showToolPicker() {
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
        canvasView.backgroundColor = UIColor.gray
        canvasView.isOpaque = true
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
        guard !toolPicker.isVisible else { return }
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
//patent na zapobieganie "pustym zmiana"
//dodaje PkToolPickerObserver do koordyantora
extension Coordinator: PKCanvasViewDelegate, PKToolPickerObserver {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard !canvasView.drawing.bounds.isEmpty else { return }
        onSaved()
    }
    
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
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

extension PKDrawing {
    func recognizeText(completion: @escaping (String?) -> Void) {
        // KOnwersja PKDrawing na UIImage (tuaj moze mozna to zastapic ale to potem)
        let drawingImage = self.image(from: self.bounds, scale: UIScreen.main.scale)
        
        // przygotowanie zadania do rozpoznawania tekstu
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion(nil)
                return
            }
            
            // zbieranie rozpoznanego tekstu z all obserwacji
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // ustawienie tesktu, polaczenie linii
            let recognizedText = recognizedStrings.joined(separator: " ")
            completion(recognizedText)
        }
        
        //konfig rozpoznawania - mozemy tutaj dostoswac jesli bedzie cos nie tak, dla pisma odrecznego testy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["pl", "en"]
        
        //zeby wykonywalo sie to wszystko w tle
        DispatchQueue.global(qos: .userInitiated).async {
            let requestHandler = VNImageRequestHandler(cgImage: drawingImage.cgImage!, options: [:])
            try? requestHandler.perform([request])
        }
    }
}
