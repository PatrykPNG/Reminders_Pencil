//
//  ToolManager.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 14/04/2025.
//


import SwiftUI
import PencilKit

// Wedle singleton
class ToolManager {
    static let shared = ToolManager()
    let toolPicker = PKToolPicker()
    private init() {}
}
