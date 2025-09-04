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
    @State private var searchText = ""
    @State private var filteredArtworks: [Artwork] = []
    @State private var isDescriptionExpanded = false
    
    init(exhibition: Exhibition) {
        self.exhibition = exhibition
        self._viewModel = StateObject(wrappedValue: ExhibitionDetailViewModel(exhibition: exhibition))
    }
    
    private var shouldShowReadMore: Bool {
        let description = exhibition.displayDescription
        // Check if description is long enough to warrant a "Read more" button
        return !description.isEmpty && description.count > 200
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar at the top - fixed
            searchBar
            
            // Main scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    // Exhibition name section
                    exhibitionNameSection
                    
                    // Content area
                    if viewModel.artworks.isEmpty && !viewModel.isLoading {
                        emptyStateView
                            .frame(minHeight: 400)
                    } else if filteredArtworks.isEmpty && !searchText.isEmpty {
                        searchEmptyStateView
                            .frame(minHeight: 400)
                    } else if filteredArtworks.isEmpty && searchText.isEmpty && !viewModel.artworks.isEmpty {
                        noPicturesStateView
                            .frame(minHeight: 400)
                    } else {
                        artworksGridContent
                    }
                    
                    if viewModel.isLoading && viewModel.artworks.isEmpty {
                        ProgressView("Loading artworks...")
                            .frame(height: 200)
                    }
                }
            }
            .refreshable {
                await viewModel.refreshArtworks()
            }
        }
        .navigationTitle("Exhibition")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CompactThemeToggle()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadArtworks()
        }
        .onChange(of: viewModel.artworks) { _, _ in
            updateFilteredArtworks()
        }
        .onAppear {
            updateFilteredArtworks()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var artworksGridContent: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredArtworks) { artwork in
                NavigationLink(destination: ArtworkDetailView(artwork: artwork, exhibition: exhibition)) {
                    ArtworkRowView(
                        artwork: artwork,
                        exhibition: exhibition,
                        isFavorite: favoritesStore.isFavorite(artworkId: artwork.id)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favoritesStore.toggleFavorite(artwork: artwork, fromExhibition: exhibition)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Prevents the NavigationLink from interfering with the heart button
                .onAppear {
                    // Only trigger pagination if we're showing all artworks (not searching)
                    if searchText.isEmpty && artwork.id == viewModel.artworks.last?.id {
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
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
    
    private var noPicturesStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No pictures of the pieces found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("This exhibition has artworks, but none have available images to display.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                Task {
                    await viewModel.refreshArtworks()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)
                
                TextField("Search artworks in this exhibition", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { _, newValue in
                        updateFilteredArtworks()
                    }
                
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
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var exhibitionNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exhibition.displayTitle)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !exhibition.displayDescription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exhibition.displayDescription)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isDescriptionExpanded ? nil : 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if shouldShowReadMore {
                        HStack {
                            Text(isDescriptionExpanded ? "Read less" : "Read more")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                                .onTapGesture {
                                    print("Read more tapped - current state: \(isDescriptionExpanded)")
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isDescriptionExpanded.toggle()
                                    }
                                    print("New state: \(isDescriptionExpanded)")
                                }
                                .allowsHitTesting(true)
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No artworks found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("No artworks in this exhibition match your search for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Clear Search") {
                searchText = ""
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func updateFilteredArtworks() {
        // First filter to only include artworks with valid image URLs
        let artworksWithImages = viewModel.artworks.filter { artwork in
            artwork.imageURL != nil && artwork.primaryimageurl != nil && !artwork.primaryimageurl!.isEmpty
        }
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            filteredArtworks = artworksWithImages
            return
        }
        
        let searchQuery = searchText.lowercased()
        let filtered = artworksWithImages.filter { artwork in
            artwork.displayTitle.lowercased().contains(searchQuery) ||
            artwork.displayArtist.lowercased().contains(searchQuery) ||
            artwork.displayDescription.lowercased().contains(searchQuery) ||
            artwork.displayDate.lowercased().contains(searchQuery)
        }
        
        filteredArtworks = filtered
    }
}

struct ArtworkRowView: View {
    let artwork: Artwork
    let exhibition: Exhibition
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Artwork image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: artwork.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.5)
                        )
                }
                .frame(width: 80, height: 80)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(isFavorite ? .red : .white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                        )
                }
                .padding(6)
            }
            
            // Right side - Artwork details
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.displayTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.tail)
                
                Text(artwork.displayArtist)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.tail)
                
                Text(artwork.displayDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.tail)
                
                // Description if available
                if !artwork.displayDescription.isEmpty {
                    Text(artwork.displayDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .truncationMode(.tail)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
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
