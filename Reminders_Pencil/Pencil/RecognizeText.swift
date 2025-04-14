//
//  RecognizeText.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 14/04/2025.
//

import SwiftUI
import PencilKit
import Vision

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
        request.usesLanguageCorrection = false
        
        //zeby wykonywalo sie to wszystko w tle
        DispatchQueue.global(qos: .userInitiated).async {
            let requestHandler = VNImageRequestHandler(cgImage: drawingImage.cgImage!, options: [:])
            try? requestHandler.perform([request])
        }
    }
}
