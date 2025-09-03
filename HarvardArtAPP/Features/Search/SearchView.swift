//
//  SearchView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var searchText = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Fixed header area
                VStack(spacing: 0) {
                    // Search bar at the top
                    searchBar
                    
                    // Filter chips
                    filterChips
                }
                .background(Color(.systemBackground))
                
                // Content area
                ZStack {
                    if searchText.isEmpty {
                        emptySearchState
                    } else if viewModel.artworks.isEmpty && !viewModel.isLoading {
                        noResultsState
                    } else {
                        searchResults
                    }
                    
                    if viewModel.isLoading && viewModel.artworks.isEmpty {
                        ProgressView("Searching...")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.clearError() }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 12)
            
            TextField("Search for an artwork", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { _, newValue in
                    viewModel.scheduleSearch(query: newValue)
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.clearResults()
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
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Exhibitions", isSelected: false)
                FilterChip(title: "Artwork", isSelected: false)
                FilterChip(title: "Artists", isSelected: false)
                FilterChip(title: "Mediums", isSelected: false)
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    private var searchResults: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 20) {
                ForEach(viewModel.artworks) { artwork in
                    SearchResultCardView(
                        artwork: artwork,
                        isFavorite: favoritesStore.isFavorite(artworkId: artwork.id)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            // For search results, we don't have a specific exhibition context
                            // So we'll create a generic one or use the first available exhibition
                            let genericExhibition = Exhibition(
                                id: 0,
                                title: "Search Results",
                                description: "Artwork found through search",
                                primaryimageurl: nil,
                                begindate: nil,
                                enddate: nil
                            )
                            favoritesStore.toggleFavorite(artwork: artwork, fromExhibition: genericExhibition)
                        }
                    }
                    .onAppear {
                        if artwork.id == viewModel.artworks.last?.id {
                            Task {
                                await viewModel.loadMoreResults()
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
    
    private var emptySearchState: some View {
        // Just show empty space when no search is active
        Spacer()
    }
    
    private var noResultsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Try different keywords or check your spelling")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            await viewModel.search(query: searchText)
        }
    }
}

struct SearchResultCardView: View {
    let artwork: Artwork
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

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    SearchView()
        .environmentObject(FavoritesStore.shared)
}
