//
//  ExhibitionDetailView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ExhibitionDetailView: View {
    let exhibition: Exhibition
    @StateObject private var viewModel: ExhibitionDetailViewModel
    @EnvironmentObject private var favoritesStore: FavoritesStore
    
    init(exhibition: Exhibition) {
        self.exhibition = exhibition
        self._viewModel = StateObject(wrappedValue: ExhibitionDetailViewModel(exhibition: exhibition))
    }
    
    var body: some View {
        ZStack {
            if viewModel.artworks.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                artworksGrid
            }
            
            if viewModel.isLoading && viewModel.artworks.isEmpty {
                ProgressView("Loading artworks...")
            }
        }
        .navigationTitle(exhibition.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.refreshArtworks()
        }
        .task {
            await viewModel.loadArtworks()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var artworksGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 20) {
                ForEach(viewModel.artworks) { artwork in
                    ArtworkCardView(
                        artwork: artwork,
                        exhibition: exhibition,
                        isFavorite: favoritesStore.isFavorite(artworkId: artwork.id)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favoritesStore.toggleFavorite(artwork: artwork, fromExhibition: exhibition)
                        }
                    }
                    .onAppear {
                        if artwork.id == viewModel.artworks.last?.id {
                            Task {
                                await viewModel.loadMoreArtworks()
                            }
                        }
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
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No artworks found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("This exhibition doesn't have any artworks with images available.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.refreshArtworks()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ArtworkCardView: View {
    let artwork: Artwork
    let exhibition: Exhibition
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: artwork.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite ? .red : .white)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 30, height: 30)
                        )
                }
                .padding(8)
            }
            
            // Text content section
            VStack(alignment: .leading, spacing: 3) {
                Text(artwork.displayTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(artwork.displayArtist)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(artwork.displayDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(artwork.displayDescription)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        )
        .frame(maxHeight: 240) // Set maximum height to prevent overflow
    }
}

#Preview {
    let exhibition = Exhibition(
        id: 1,
        title: "Van Gogh Exhibition",
        description: "A comprehensive look at the work of Vincent van Gogh",
        primaryimageurl: nil,
        begindate: "2023",
        enddate: "2024"
    )
    
    NavigationView {
        ExhibitionDetailView(exhibition: exhibition)
            .environmentObject(FavoritesStore.shared)
    }
}
