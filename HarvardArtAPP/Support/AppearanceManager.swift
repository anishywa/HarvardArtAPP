//
//  AppearanceManager.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    
    @Published var currentMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "appearance_mode")
        }
    }
    
    private init() {
        let savedMode = UserDefaults.standard.string(forKey: "appearance_mode") ?? AppearanceMode.system.rawValue
        self.currentMode = AppearanceMode(rawValue: savedMode) ?? .system
    }
    
    func toggleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentMode {
            case .system:
                currentMode = .light
            case .light:
                currentMode = .dark
            case .dark:
                currentMode = .system
            }
        }
    }
}
