//
//  EKEventEditViewController.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 20/04/2025.
//

import EventKit
import EventKitUI
import SwiftUI

struct EventEditViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var completedAction: EKEventEditViewAction?
    @Binding var event: EKEvent?
    private let eventStore: EKEventStore

    init(store: EKEventStore, event: Binding<EKEvent?>, isPresented: Binding<Bool>, completedAction: Binding<EKEventEditViewAction?>) {
        self._isPresented = isPresented
        self._completedAction = completedAction
        self._event = event
        self.eventStore = store
    }
    
    typealias UIViewControllerType = EKEventEditViewController
    

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
 
        var parent: EventEditViewControllerRepresentable
        
        init(_ parent: EventEditViewControllerRepresentable) {
            self.parent = parent
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.completedAction = action
            parent.isPresented = false
        }
    }
}


extension EKEventEditViewAction: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .canceled:
            "Edit Canceled"
        case .saved:
            "Event Saved"
        case .deleted:
            "Event Deleted"
        @unknown default:
            "Unknown action"
        }
    }
}
