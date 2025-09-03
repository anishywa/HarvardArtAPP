//
//  FavoritesStore.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation
import SwiftUI

class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()
    
    @Published private(set) var favoriteArtworks: [FavoriteArtwork] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteArtworks"
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    func isFavorite(artworkId: Int) -> Bool {
        favoriteArtworks.contains { $0.id == artworkId }
    }
    
    func toggleFavorite(artwork: Artwork, fromExhibition exhibition: Exhibition) {
        if let index = favoriteArtworks.firstIndex(where: { $0.id == artwork.id }) {
            favoriteArtworks.remove(at: index)
        } else {
            let favoriteArtwork = FavoriteArtwork(
                id: artwork.id,
                title: artwork.displayTitle,
                artist: artwork.displayArtist,
                dated: artwork.displayDate,
                description: artwork.displayDescription,
                imageURL: artwork.primaryimageurl,
                exhibitionId: exhibition.id,
                exhibitionTitle: exhibition.displayTitle
            )
            favoriteArtworks.append(favoriteArtwork)
        }
        
        saveFavorites()
    }
    
    func groupedFavorites() -> [String: [FavoriteArtwork]] {
        Dictionary(grouping: favoriteArtworks) { $0.exhibitionTitle }
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode([FavoriteArtwork].self, from: data) {
            self.favoriteArtworks = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteArtworks) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}

// MARK: - FavoriteArtwork Model

struct FavoriteArtwork: Codable, Identifiable {
    let id: Int
    let title: String
    let artist: String
    let dated: String
    let description: String
    let imageURL: String?
    let exhibitionId: Int
    let exhibitionTitle: String
    
    var displayImageURL: URL? {
        guard let urlString = imageURL, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
