//
//  ExhibitionDetailViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class ExhibitionDetailViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private let exhibition: Exhibition
    private let apiClient = APIClient.shared
    private var currentPage = 1
    private var hasMorePages = true
    
    init(exhibition: Exhibition) {
        self.exhibition = exhibition
    }
    
    func loadArtworks() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.fetchArtworksInExhibition(
                exhibitionId: exhibition.id,
                page: 1
            )
            artworks = response.records
            currentPage = 1
            hasMorePages = response.info.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshArtworks() async {
        artworks = []
        currentPage = 1
        hasMorePages = true
        await loadArtworks()
    }
    
    func loadMoreArtworks() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await apiClient.fetchArtworksInExhibition(
                exhibitionId: exhibition.id,
                page: nextPage
            )
            artworks.append(contentsOf: response.records)
            currentPage = nextPage
            hasMorePages = response.info.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
