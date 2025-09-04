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
    @StateObject private var searchHistoryStore = SearchHistoryStore.shared
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
                        recentSearchesView
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ThemeToggle()
            }
        }
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
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                // Save the clicked artwork to search history
                                searchHistoryStore.addClickedResultToHistory(
                                    result: .artwork(artwork),
                                    originalQuery: searchText,
                                    category: selectedCategory ?? .all
                                )
                            }
                        )
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
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                // Save the clicked result to search history
                                searchHistoryStore.addClickedResultToHistory(
                                    result: result,
                                    originalQuery: searchText,
                                    category: selectedCategory ?? .all
                                )
                            }
                        )
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
    
    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !searchHistoryStore.recentSearches.isEmpty {
                    // Header with clear option
                    HStack {
                        Text("Recent")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Clear all") {
                            searchHistoryStore.clearSearchHistory()
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Recent searches list
                    LazyVStack(spacing: 0) {
                        ForEach(searchHistoryStore.recentSearches) { historyItem in
                            RecentSearchItemView(
                                historyItem: historyItem,
                                onTap: {
                                    // If this is a clicked result, navigation is handled by NavigationLink
                                    if !historyItem.isClickedResult {
                                        // Restore the search for regular search queries
                                        searchText = historyItem.query
                                        selectedCategory = historyItem.category == .all ? nil : historyItem.category
                                        performSearch()
                                    }
                                },
                                onDelete: {
                                    searchHistoryStore.removeSearchFromHistory(id: historyItem.id)
                                },
                                destinationView: {
                                    if historyItem.isClickedResult,
                                       let preview = historyItem.resultPreview,
                                       let result = preview.toSearchResult() {
                                        return AnyView(destinationView(for: result))
                                    }
                                    return nil
                                }
                            )
                        }
                    }
                } else {
                    // Empty state when no recent searches
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No recent searches")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Your recent searches will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
        }
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
            // Simple detail view for mediums/classifications
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(classification.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Classification")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                }
                
                if let objectCount = classification.objectcount, objectCount > 0 {
                    VStack(spacing: 8) {
                        Text("Available Artworks")
                            .font(.headline)
                        
                        Text(classification.displayCount)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Medium")
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
            // Image or placeholder - larger and more prominent
            if let imageURL = result.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: iconForResult(result))
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Icon based on result type
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: iconForResult(result))
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                }
            }
            
            // Content - improved typography and spacing
            VStack(alignment: .leading, spacing: 6) {
                // Title - main name/title
                Text(result.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Type indicator
                Text(typeLabel(for: result))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                // Subtitle - artist, date, etc.
                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Description - optional additional info
                if !result.description.isEmpty && result.description != result.subtitle {
                    Text(result.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
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
    
    private func typeLabel(for result: SearchResult) -> String {
        switch result {
        case .artwork:
            return "Artwork"
        case .exhibition:
            return "Exhibition"
        case .artist:
            return "Artist"
        case .medium:
            return "Medium"
        }
    }
}

struct RecentSearchItemView: View {
    let historyItem: SearchHistoryItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let destinationView: () -> AnyView?
    
    var body: some View {
        Group {
            if historyItem.isClickedResult, let destination = destinationView() {
                NavigationLink(destination: destination) {
                    historyItemContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: onTap) {
                    historyItemContent
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var historyItemContent: some View {
        HStack(spacing: 12) {
            // Profile-like circle with search icon or result image
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
                
                if let preview = historyItem.resultPreview,
                   let imageURLString = preview.imageURL,
                   let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray5))
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Image(systemName: iconForCategory(historyItem.category))
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
            
            // Search details
            VStack(alignment: .leading, spacing: 2) {
                Text(historyItem.displayTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(historyItem.displayCategory)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(historyItem.timeAgo)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func iconForCategory(_ category: SearchCategory) -> String {
        switch category {
        case .artwork:
            return "photo"
        case .exhibitions:
            return "building.columns"
        case .artists:
            return "person"
        case .mediums:
            return "paintbrush"
        case .all:
            return "magnifyingglass"
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(FavoritesStore.shared)
}
