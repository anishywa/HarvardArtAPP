//
//  ArtistDetailView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ArtistDetailView: View {
    let artist: Person
    @StateObject private var viewModel = ArtistDetailViewModel()
    @EnvironmentObject private var favoritesStore: FavoritesStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Artist Header
                artistHeader
                
                // Artist Information
                if !artist.displayDescription.isEmpty {
                    artistInfo
                }
                
                // Artist's Artworks Section
                if !viewModel.artworks.isEmpty {
                    artistArtworks
                } else if viewModel.isLoading {
                    loadingView
                } else if !viewModel.errorMessage.isEmpty {
                    errorView
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle(artist.displayName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadArtworksByArtist(artistId: artist.id ?? 0)
        }
        .refreshable {
            await viewModel.refreshArtworks()
        }
    }
    
    private var artistHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(artist.displayName)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.leading)
            
            if !artist.displayDates.isEmpty {
                Text(artist.displayDates)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if !artist.displayBirthPlace.isEmpty {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                    Text(artist.displayBirthPlace)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 4)
    }
    
    private var artistInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .semibold))
            
            Text(artist.displayDescription)
                .font(.system(size: 16))
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var artistArtworks: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Artworks")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Text("\(viewModel.artworks.count) pieces")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(viewModel.artworks) { artwork in
                    NavigationLink(destination: ArtworkDetailView(artwork: artwork, exhibition: Exhibition(
                        id: 0,
                        title: "Artist Collection",
                        description: "Artworks by \(artist.displayName)",
                        primaryimageurl: nil,
                        begindate: nil,
                        enddate: nil
                    ))) {
                        ArtistArtworkCardView(
                            artwork: artwork,
                            isFavorite: favoritesStore.isFavorite(artworkId: artwork.id)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                let genericExhibition = Exhibition(
                                    id: 0,
                                    title: "Artist Collection",
                                    description: "Artworks by \(artist.displayName)",
                                    primaryimageurl: nil,
                                    begindate: nil,
                                    enddate: nil
                                )
                                favoritesStore.toggleFavorite(artwork: artwork, fromExhibition: genericExhibition)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading artworks...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Unable to load artworks")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadArtworksByArtist(artistId: artist.id ?? 0)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ArtistArtworkCardView: View {
    let artwork: Artwork
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Artwork Image
            ZStack(alignment: .topTrailing) {
                if let imageURL = artwork.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 160)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                        )
                }
                .padding(8)
            }
            
            // Artwork Info
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.displayTitle)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !artwork.displayDate.isEmpty {
                    Text(artwork.displayDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .clipped()
    }
}

// MARK: - Extensions

extension Person {
    var displayName: String {
        return name ?? "Unknown Artist"
    }
    
    var displayDescription: String {
        return "" // Person model doesn't seem to have description field
    }
    
    var displayDates: String {
        if let birthDate = birthdate, let deathDate = deathdate {
            return "\(birthDate) - \(deathDate)"
        } else if let birthDate = birthdate {
            return "b. \(birthDate)"
        } else if let deathDate = deathdate {
            return "d. \(deathDate)"
        }
        return ""
    }
    
    var displayBirthPlace: String {
        return birthplace ?? ""
    }
}

#Preview {
    NavigationStack {
        ArtistDetailView(artist: Person(
            id: 1,
            name: "Claude Monet",
            role: "artist",
            displayname: "Claude Monet",
            objectcount: 25,
            birthdate: "1840",
            deathdate: "1926",
            birthplace: "Paris, France"
        ))
    }
    .environmentObject(FavoritesStore.shared)
}
