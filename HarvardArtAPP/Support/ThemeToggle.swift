//
//  ThemeToggle.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ThemeToggle: View {
    @ObservedObject private var appearanceManager = AppearanceManager.shared
    @State private var isExpanded = false
    
    var body: some View {
        HStack(spacing: 0) {
            if isExpanded {
                // Mode labels with smooth transition
                HStack(spacing: 12) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appearanceManager.currentMode = mode
                                isExpanded = false
                            }
                        }) {
                            Text(mode.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(appearanceManager.currentMode == mode ? .white : .primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(appearanceManager.currentMode == mode ? Color.blue : Color.clear)
                                )
                        }
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            // Toggle button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if isExpanded {
                        isExpanded = false
                    } else {
                        isExpanded = true
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: currentModeIcon)
                        .font(.system(size: 14, weight: .medium))
                    
                    if !isExpanded {
                        Text(appearanceManager.currentMode.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .onTapGesture {
            // Tap outside to close
            if isExpanded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded = false
                }
            }
        }
    }
    
    private var currentModeIcon: String {
        switch appearanceManager.currentMode {
        case .system:
            return "gear"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

struct CompactThemeToggle: View {
    @ObservedObject private var appearanceManager = AppearanceManager.shared
    
    var body: some View {
        Button(action: {
            appearanceManager.toggleMode()
        }) {
            Image(systemName: currentModeIcon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(.systemGray6))
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                )
        }
    }
    
    private var currentModeIcon: String {
        switch appearanceManager.currentMode {
        case .system:
            return "gear"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

#Preview("Theme Toggle") {
    VStack(spacing: 20) {
        ThemeToggle()
        CompactThemeToggle()
    }
    .padding()
}
