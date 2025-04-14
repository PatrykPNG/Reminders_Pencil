//
//  RecognizeText.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 14/04/2025.
//

import SwiftUI
import PencilKit
import Vision

//Sposobem na obejscie moze byc zablokowanie uzytkownikowi korzystanie z koloru w 100 procentach czarnego, badz edycja koloru czarnego na 99 procent czarnego.

extension PKDrawing {
    func recognizeText(completion: @escaping (String?) -> Void) {
        // KOnwersja PKDrawing na UIImage (tuaj moze mozna to zastapic ale to potem)
        let drawingImage = self.image(from: self.bounds, scale: UIScreen.main.scale)
        
        // przygotowanie zadania do rozpoznawania tekstu
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Error recognizing text: \(error?.localizedDescription ?? "Unknown error")")
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
        
        // ustawienie rewqizji na 2
        request.revision = 2
        
        //konfig rozpoznawania - mozemy tutaj dostoswac jesli bedzie cos nie tak, dla pisma odrecznego testy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
//        request.recognitionLanguages = ["en-US", "fr-FR"]
        
        //zeby wykonywalo sie to wszystko w tle
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let requestHandler = VNImageRequestHandler(cgImage: drawingImage.cgImage!, options: [:])
                try requestHandler.perform([request])
            } catch {
                print("Error performing text recognition: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
