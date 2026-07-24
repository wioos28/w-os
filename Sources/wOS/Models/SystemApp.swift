// SystemApp.swift
// Ported 1:1 from src/data/systemApps.js (SYSTEM_APPS / SYSTEM_APP_LIST / DOCK_APP_IDS).
import SwiftUI

struct SystemApp: Identifiable, Hashable {
    let id: String        // e.g. "settings"
    let title: String      // Vietnamese display title
    let icon: IconRef
    let color: Color
}
