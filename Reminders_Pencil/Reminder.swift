//
//  Reminder.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 01/04/2025.
//

import Foundation
import SwiftData
import PencilKit

@Model
class Reminder {
    var title: String
    var isCompleted: Bool = false
    var order: Int
    var drawingData: Data?
    
    init(title: String, order: Int) {
        self.title = title
        self.order = order
    }
}
