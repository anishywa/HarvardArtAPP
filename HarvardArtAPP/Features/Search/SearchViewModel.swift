//
//  SearchViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private var currentQuery = ""
    private var currentPage = 1
    private var hasMorePages = true
    private var searchTask: Task<Void, Never>?
    
    func scheduleSearch(query: String) {
        // Cancel previous search
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            clearResults()
            return
        }
        
        // Debounce search by 300ms
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                
                if !Task.isCancelled {
                    await search(query: trimmedQuery)
                }
            } catch {
                // Task was cancelled, which is expected behavior - don't treat as error
                return
            }
        }
    }
    
    func search(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        // If it's a new query, reset everything
        if trimmedQuery != currentQuery {
            artworks = []
            currentPage = 1
            hasMorePages = true
            currentQuery = trimmedQuery
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.searchArtworks(query: trimmedQuery, page: 1)
            artworks = response.records
            currentPage = 1
            hasMorePages = response.info.hasNextPage
        } catch {
            // Don't show error for cancelled tasks
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func loadMoreResults() async {
        guard !isLoadingMore && hasMorePages && !currentQuery.isEmpty else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await apiClient.searchArtworks(query: currentQuery, page: nextPage)
            artworks.append(contentsOf: response.records)
            currentPage = nextPage
            hasMorePages = response.info.hasNextPage
        } catch {
            // Don't show error for cancelled tasks
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoadingMore = false
    }
    
    func clearResults() {
        searchTask?.cancel()
        artworks = []
        currentQuery = ""
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}
