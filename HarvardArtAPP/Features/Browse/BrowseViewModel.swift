//
//  BrowseViewModel.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var exhibitions: [Exhibition] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private var currentPage = 1
    private var hasMorePages = true
    
    func loadExhibitions() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.fetchExhibitions(page: 1)
            exhibitions = response.records
            currentPage = 1
            hasMorePages = response.info.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshExhibitions() async {
        exhibitions = []
        currentPage = 1
        hasMorePages = true
        await loadExhibitions()
    }
    
    func loadMoreExhibitions() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await apiClient.fetchExhibitions(page: nextPage)
            exhibitions.append(contentsOf: response.records)
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
