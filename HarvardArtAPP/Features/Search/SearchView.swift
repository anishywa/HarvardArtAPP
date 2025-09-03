//
//  SearchView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

enum SearchCategory: String, CaseIterable {
    case exhibitions = "Exhibitions"
    case artwork = "Artwork"
    case artists = "Artists"
    case mediums = "Mediums"
    case all = "All" // Added for general search
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory? = nil
    
    private var placeholderText: String {
        if let category = selectedCategory {
            switch category {
            case .artwork:
                return "Search for an artwork"
            case .exhibitions:
                return "Search for exhibitions"
            case .artists:
                return "Search for artists"
            case .mediums:
                return "Search for mediums"
            case .all:
                return "Search everything"
            }
        } else {
            return "Search everything"
        }
    }
    
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
                                    } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                    noResultsState
                } else {
                    searchResults
                }
                    
                                    if viewModel.isLoading && viewModel.searchResults.isEmpty {
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
            
            TextField(placeholderText, text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { _, newValue in
                    viewModel.scheduleSearch(query: newValue, category: selectedCategory ?? .all)
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
                ForEach(SearchCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        // Toggle category selection - allow deselection
                        if selectedCategory == category {
                            selectedCategory = nil // Deselect current category
                        } else {
                            selectedCategory = category // Select new category
                        }
                        
                        if !searchText.isEmpty {
                            Task {
                                await viewModel.search(query: searchText, category: selectedCategory ?? .all)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    private var searchResults: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if selectedCategory == .artwork {
                // Grid layout for artworks only
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 20) {
                    ForEach(viewModel.artworks) { artwork in
                        NavigationLink(destination: ArtworkDetailView(artwork: artwork, exhibition: Exhibition(
                            id: 0,
                            title: "Search Results",
                            description: "Artwork found through search",
                            primaryimageurl: nil,
                            begindate: nil,
                            enddate: nil
                        ))) {
                            SearchResultCardView(
                                artwork: artwork,
                                isFavorite: favoritesStore.isFavorite(artworkId: artwork.id)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            } else {
                // List layout for other categories or general search (when no category selected)
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.searchResults) { result in
                        NavigationLink(destination: destinationView(for: result)) {
                            UniversalSearchResultView(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
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
            await viewModel.search(query: searchText, category: selectedCategory ?? .all)
        }
    }
    
    @ViewBuilder
    private func destinationView(for result: SearchResult) -> some View {
        switch result {
        case .artwork(let artwork):
            ArtworkDetailView(artwork: artwork, exhibition: Exhibition(
                id: 0,
                title: "Search Results",
                description: "Artwork found through search",
                primaryimageurl: nil,
                begindate: nil,
                enddate: nil
            ))
        case .exhibition(let exhibition):
            ExhibitionDetailView(exhibition: exhibition)
        case .artist(let artist):
            ArtistDetailView(artist: artist)
        case .medium(let classification):
            // For now, show a simple text view for mediums
            // You could create a MediumDetailView if needed
            VStack(spacing: 20) {
                Text(classification.name ?? "Unknown Medium")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let description = classification.name {
                    Text("Medium: \(description)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Medium Details")
            .navigationBarTitleDisplayMode(.large)
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct UniversalSearchResultView: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Image or placeholder
            if let imageURL = result.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Icon based on result type
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconForResult(result))
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !result.description.isEmpty {
                    Text(result.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func iconForResult(_ result: SearchResult) -> String {
        switch result {
        case .artwork:
            return "photo"
        case .exhibition:
            return "building.columns"
        case .artist:
            return "person"
        case .medium:
            return "paintbrush"
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(FavoritesStore.shared)
}
