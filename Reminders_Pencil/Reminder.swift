//
//  Reminder.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 01/04/2025.
//

import Foundation
import SwiftData

@Model
class Reminder {
    var title: String
    var isCompleted: Bool = false
    var order: Int
    
    init(title: String, order: Int) {
        self.title = title
        self.order = order
    }
}
