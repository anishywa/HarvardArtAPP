//
//  ArtistDetailViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class ArtistDetailViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage = ""
    
    private let apiClient = APIClient.shared
    private var currentPage = 1
    private var hasMorePages = true
    private var currentArtistId = 0
    
    func loadArtworksByArtist(artistId: Int) async {
        guard !isLoading else { return }
        
        currentArtistId = artistId
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await apiClient.fetchArtworksByArtist(artistId: artistId, page: 1)
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
        await loadArtworksByArtist(artistId: currentArtistId)
    }
    
    func loadMoreArtworks() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await apiClient.fetchArtworksByArtist(artistId: currentArtistId, page: nextPage)
            artworks.append(contentsOf: response.records)
            currentPage = nextPage
            hasMorePages = response.info.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    func clearError() {
        errorMessage = ""
    }
}
