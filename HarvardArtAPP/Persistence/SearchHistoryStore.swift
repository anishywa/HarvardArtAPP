//
//  SearchHistoryStore.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation
import SwiftUI

class SearchHistoryStore: ObservableObject {
    static let shared = SearchHistoryStore()
    
    @Published private(set) var recentSearches: [SearchHistoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let searchHistoryKey = "SearchHistory"
    private let maxHistoryItems = 10 // Limit to keep it manageable
    
    init() {
        loadSearchHistory()
    }
    
    // MARK: - Public Methods
    
    func addSearchToHistory(query: String, category: SearchCategory, result: SearchResult? = nil) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        // Remove existing entry if it exists
        recentSearches.removeAll { $0.query.lowercased() == trimmedQuery.lowercased() && $0.category == category }
        
        // Create new search history item
        let historyItem = SearchHistoryItem(
            query: trimmedQuery,
            category: category,
            timestamp: Date(),
            resultPreview: result
        )
        
        // Add to beginning of array
        recentSearches.insert(historyItem, at: 0)
        
        // Keep only the most recent items
        if recentSearches.count > maxHistoryItems {
            recentSearches = Array(recentSearches.prefix(maxHistoryItems))
        }
        
        saveSearchHistory()
    }
    
    func addClickedResultToHistory(result: SearchResult, originalQuery: String, category: SearchCategory) {
        // Remove existing entry if it exists (based on result title to avoid duplicates)
        recentSearches.removeAll { $0.resultPreview?.title.lowercased() == result.title.lowercased() }
        
        // Create new search history item with the clicked result
        let historyItem = SearchHistoryItem(
            query: originalQuery,
            category: category,
            timestamp: Date(),
            resultPreview: result,
            isClickedResult: true
        )
        
        // Add to beginning of array
        recentSearches.insert(historyItem, at: 0)
        
        // Keep only the most recent items
        if recentSearches.count > maxHistoryItems {
            recentSearches = Array(recentSearches.prefix(maxHistoryItems))
        }
        
        saveSearchHistory()
    }
    
    func removeSearchFromHistory(id: String) {
        recentSearches.removeAll { $0.id == id }
        saveSearchHistory()
    }
    
    func clearSearchHistory() {
        recentSearches.removeAll()
        saveSearchHistory()
    }
    
    // MARK: - Private Methods
    
    private func loadSearchHistory() {
        if let data = userDefaults.data(forKey: searchHistoryKey),
           let history = try? JSONDecoder().decode([SearchHistoryItem].self, from: data) {
            self.recentSearches = history
        }
    }
    
    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            userDefaults.set(data, forKey: searchHistoryKey)
        }
    }
}

// MARK: - SearchHistoryItem Model

struct SearchHistoryItem: Codable, Identifiable {
    let id: String
    let query: String
    let category: SearchCategory
    let timestamp: Date
    let resultPreview: SearchResultPreview?
    let isClickedResult: Bool
    
    init(query: String, category: SearchCategory, timestamp: Date, resultPreview: SearchResult? = nil, isClickedResult: Bool = false) {
        self.id = UUID().uuidString
        self.query = query
        self.category = category
        self.timestamp = timestamp
        self.resultPreview = resultPreview?.toPreview()
        self.isClickedResult = isClickedResult
    }
    
    // Custom decoder to handle legacy data without isClickedResult
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        query = try container.decode(String.self, forKey: .query)
        category = try container.decode(SearchCategory.self, forKey: .category)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        resultPreview = try container.decodeIfPresent(SearchResultPreview.self, forKey: .resultPreview)
        isClickedResult = try container.decodeIfPresent(Bool.self, forKey: .isClickedResult) ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, query, category, timestamp, resultPreview, isClickedResult
    }
    
    var displayTitle: String {
        // If this is a clicked result, show the result title instead of the query
        if isClickedResult, let preview = resultPreview {
            return preview.title
        }
        return query
    }
    
    var displayCategory: String {
        return category == .all ? "All" : category.rawValue
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - SearchResultPreview Model (for storage)

struct SearchResultPreview: Codable {
    let title: String
    let subtitle: String
    let description: String
    let imageURL: String?
    let type: SearchResultType
}

enum SearchResultType: String, Codable {
    case artwork = "artwork"
    case exhibition = "exhibition"
    case artist = "artist"
    case medium = "medium"
}

extension SearchResult {
    func toPreview() -> SearchResultPreview {
        let type: SearchResultType
        switch self {
        case .artwork: type = .artwork
        case .exhibition: type = .exhibition
        case .artist: type = .artist
        case .medium: type = .medium
        }
        
        return SearchResultPreview(
            title: self.title,
            subtitle: self.subtitle,
            description: self.description,
            imageURL: self.imageURL?.absoluteString,
            type: type
        )
    }
}

extension SearchCategory: Codable {}

// MARK: - SearchResultPreview Extensions

extension SearchResultPreview {
    func toSearchResult() -> SearchResult? {
        switch type {
        case .artwork:
            // Create a minimal Artwork object for navigation
            let artwork = Artwork(
                id: 0, // We don't have the original ID, but it's not needed for display
                title: title,
                dated: subtitle,
                description: description.isEmpty ? nil : description,
                labeltext: nil,
                primaryimageurl: imageURL,
                people: nil
            )
            return .artwork(artwork)
            
        case .exhibition:
            let exhibition = Exhibition(
                id: 0,
                title: title,
                description: description.isEmpty ? nil : description,
                primaryimageurl: imageURL,
                begindate: nil,
                enddate: nil
            )
            return .exhibition(exhibition)
            
        case .artist:
            let person = Person(
                id: nil,
                name: title,
                role: subtitle,
                displayname: title,
                objectcount: nil,
                birthdate: nil,
                deathdate: nil,
                birthplace: nil
            )
            return .artist(person)
            
        case .medium:
            let classification = Classification(
                id: 0,
                name: title,
                objectcount: nil
            )
            return .medium(classification)
        }
    }
}
