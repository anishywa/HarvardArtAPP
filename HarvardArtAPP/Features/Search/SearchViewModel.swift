//
//  SearchViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private var currentQuery = ""
    private var currentCategory: SearchCategory = .artwork
    private var currentPage = 1
    private var hasMorePages = true
    private var searchTask: Task<Void, Never>?
    
    // Keep artworks for backward compatibility with favorites functionality
    var artworks: [Artwork] {
        searchResults.compactMap { result in
            if case .artwork(let artwork) = result {
                return artwork
            }
            return nil
        }
    }
    
    func scheduleSearch(query: String, category: SearchCategory) {
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
                    await search(query: trimmedQuery, category: category)
                }
            } catch {
                // Task was cancelled, which is expected behavior - don't treat as error
                return
            }
        }
    }
    
    func search(query: String, category: SearchCategory) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        // If it's a new query or category, reset everything
        if trimmedQuery != currentQuery || category != currentCategory {
            searchResults = []
            currentPage = 1
            hasMorePages = true
            currentQuery = trimmedQuery
            currentCategory = category
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await performSearch(query: trimmedQuery, category: category, page: 1)
            searchResults = results
            currentPage = 1
            hasMorePages = true // We'll implement pagination later if needed
            
            // Debug logging for artist and medium searches
            if category == .artists || category == .mediums {
                print("🔍 Search completed for \(category.rawValue): '\(trimmedQuery)'")
                print("📊 Results found: \(results.count)")
            }
        } catch {
            // Don't show error for cancelled tasks
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
                print("❌ Search error for \(category.rawValue): \(error.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    private func performSearch(query: String, category: SearchCategory, page: Int) async throws -> [SearchResult] {
        switch category {
        case .artwork:
            let response: APIResponse<Artwork> = try await apiClient.searchArtworks(query: query, page: page)
            return response.records.map { SearchResult.artwork($0) }
            
        case .exhibitions:
            let response: APIResponse<Exhibition> = try await apiClient.searchExhibitions(query: query, page: page)
            return response.records.map { SearchResult.exhibition($0) }
            
        case .artists:
            let response: APIResponse<Person> = try await apiClient.searchPeople(query: query, page: page)
            let results = response.records.map { SearchResult.artist($0) }
            print("🔍 Artist search API returned \(response.records.count) records")
            return results
            
        case .mediums:
            let response: APIResponse<Classification> = try await apiClient.searchClassifications(query: query, page: page)
            let results = response.records.map { SearchResult.medium($0) }
            print("🔍 Medium search API returned \(response.records.count) records")
            return results
            
        case .all:
            // Perform general search across all categories
            return try await performGeneralSearch(query: query, page: page)
        }
    }
    
    private func performGeneralSearch(query: String, page: Int) async throws -> [SearchResult] {
        // Search across multiple categories and combine results
        async let artworksTask = apiClient.searchArtworks(query: query, page: page)
        async let exhibitionsTask = apiClient.searchExhibitions(query: query, page: page)
        async let artistsTask = apiClient.searchPeople(query: query, page: page)
        
        let (artworksResponse, exhibitionsResponse, artistsResponse) = try await (artworksTask, exhibitionsTask, artistsTask)
        
        var allResults: [SearchResult] = []
        
        // Add results from each category (limit each to maintain performance)
        allResults.append(contentsOf: artworksResponse.records.prefix(5).map { SearchResult.artwork($0) })
        allResults.append(contentsOf: exhibitionsResponse.records.prefix(5).map { SearchResult.exhibition($0) })
        allResults.append(contentsOf: artistsResponse.records.prefix(5).map { SearchResult.artist($0) })
        
        return allResults
    }
    
    func loadMoreResults() async {
        guard !isLoadingMore && hasMorePages && !currentQuery.isEmpty else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let moreResults = try await performSearch(query: currentQuery, category: currentCategory, page: nextPage)
            searchResults.append(contentsOf: moreResults)
            currentPage = nextPage
            hasMorePages = true // We'll implement proper pagination later if needed
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
        searchResults = []
        currentQuery = ""
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}
