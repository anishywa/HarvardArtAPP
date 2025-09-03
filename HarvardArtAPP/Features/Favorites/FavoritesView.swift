//
//  FavoritesView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var searchText = ""
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Always show search bar at top
            favoritesSearchBar
            
            ZStack {
                if favoritesStore.favoriteArtworks.isEmpty {
                    if !searchText.isEmpty {
                        // Show search message when trying to search with no favorites
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            Text("No favorites to search")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Add some artworks to favorites first")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        emptyStateView
                    }
                } else {
                    favoritesList
                }
            }
        }
        .navigationTitle("Favorites")
    }
    
    private var favoritesList: some View {
        List {
            let filteredGroupedFavorites = filteredFavorites()
            
            if filteredGroupedFavorites.isEmpty && !searchText.isEmpty {
                // Show no results message when searching
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            Text("No favorites found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("No favorites match your search")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(Array(filteredGroupedFavorites.keys.sorted()), id: \.self) { exhibitionTitle in
                    Section(header: Text(exhibitionTitle)) {
                        let artworks = filteredGroupedFavorites[exhibitionTitle] ?? []
                        
                        ForEach(artworks) { artwork in
                            NavigationLink(destination: ArtworkDetailView(
                                artwork: Artwork(
                                    id: artwork.id,
                                    title: artwork.title,
                                    dated: artwork.dated,
                                    description: artwork.description,
                                    labeltext: nil,
                                    primaryimageurl: artwork.imageURL,
                                    people: nil
                                ),
                                exhibition: Exhibition(
                                    id: artwork.exhibitionId,
                                    title: artwork.exhibitionTitle,
                                    description: nil,
                                    primaryimageurl: nil,
                                    begindate: nil,
                                    enddate: nil
                                )
                            )) {
                                FavoriteArtworkRowView(artwork: artwork) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        // Create a dummy exhibition for unfavoriting
                                        let exhibition = Exhibition(
                                            id: artwork.exhibitionId,
                                            title: artwork.exhibitionTitle,
                                            description: nil,
                                            primaryimageurl: nil,
                                            begindate: nil,
                                            enddate: nil
                                        )
                                        
                                        // Convert FavoriteArtwork back to Artwork for unfavoriting
                                        let artworkModel = Artwork(
                                            id: artwork.id,
                                            title: artwork.title,
                                            dated: artwork.dated,
                                            description: artwork.description,
                                            labeltext: nil,
                                            primaryimageurl: artwork.imageURL,
                                            people: nil
                                        )
                                        
                                        favoritesStore.toggleFavorite(artwork: artworkModel, fromExhibition: exhibition)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("You have no favorited artworks.")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Switch to the Browse tab (tag 0)
                selectedTab = 0
            }) {
                Text("Browse art")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var favoritesSearchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 12)
            
            TextField("Search for an artwork", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 12)
            } else {
                Spacer()
                    .frame(width: 12)
            }
        }
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    private func filteredFavorites() -> [String: [FavoriteArtwork]] {
        let groupedFavorites = favoritesStore.groupedFavorites()
        
        // If no search text, return all favorites
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return groupedFavorites
        }
        
        let searchQuery = searchText.lowercased()
        var filteredGroups: [String: [FavoriteArtwork]] = [:]
        
        // Filter artworks within each exhibition group
        for (exhibitionTitle, artworks) in groupedFavorites {
            let filteredArtworks = artworks.filter { artwork in
                artwork.title.lowercased().contains(searchQuery) ||
                artwork.artist.lowercased().contains(searchQuery) ||
                artwork.description.lowercased().contains(searchQuery) ||
                artwork.dated.lowercased().contains(searchQuery) ||
                exhibitionTitle.lowercased().contains(searchQuery)
            }
            
            // Only include exhibition groups that have matching artworks
            if !filteredArtworks.isEmpty {
                filteredGroups[exhibitionTitle] = filteredArtworks
            }
        }
        
        return filteredGroups
    }
}

struct FavoriteArtworkRowView: View {
    let artwork: FavoriteArtwork
    let onRemoveFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: artwork.displayImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(artwork.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(artwork.dated)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text(artwork.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onRemoveFavorite) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FavoritesView(selectedTab: .constant(1))
        .environmentObject(FavoritesStore.shared)
}
