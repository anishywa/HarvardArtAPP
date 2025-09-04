//
//  ArtworkOverviewViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class ArtworkOverviewViewModel: ObservableObject {
    @Published var overview: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasGenerated: Bool = false
    
    private let geminiService = GeminiService.shared
    
    func generateOverview(for artwork: Artwork, exhibition: Exhibition) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let generatedOverview = try await geminiService.generateArtworkOverview(for: artwork, exhibition: exhibition)
            overview = generatedOverview
            hasGenerated = true
        } catch {
            errorMessage = error.localizedDescription
            print("Error generating overview: \(error)")
        }
        
        isLoading = false
    }
    
    func clearOverview() {
        overview = ""
        hasGenerated = false
        errorMessage = nil
    }
}
