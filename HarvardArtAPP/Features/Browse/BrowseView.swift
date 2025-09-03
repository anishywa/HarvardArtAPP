//
//  BrowseView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    @State private var searchText = ""
    @State private var filteredExhibitions: [Exhibition] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar at the top - fixed position
            searchBar
            
            // Content area - takes all remaining space
            ZStack {
                if viewModel.exhibitions.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else if filteredExhibitions.isEmpty && !searchText.isEmpty {
                    searchEmptyStateView
                } else {
                    exhibitionsList
                }
                
                if viewModel.isLoading && viewModel.exhibitions.isEmpty {
                    ProgressView("Loading exhibitions...")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.refreshExhibitions()
        }
        .task {
            await viewModel.loadExhibitions()
        }
        .onChange(of: viewModel.exhibitions) { _, _ in
            updateFilteredExhibitions()
        }
        .onAppear {
            updateFilteredExhibitions()
        }
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
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)
                
                TextField("Search for an exhibition", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { _, newValue in
                        print("Search text changed to: '\(newValue)'")
                        updateFilteredExhibitions()
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
    
    private var exhibitionsList: some View {
        List {
            ForEach(filteredExhibitions) { exhibition in
                NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                    ExhibitionCardView(exhibition: exhibition)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .onAppear {
                    if exhibition.id == viewModel.exhibitions.last?.id {
                        Task {
                            await viewModel.loadMoreExhibitions()
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
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.columns")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No exhibitions found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                Task {
                    await viewModel.refreshExhibitions()
                }
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No exhibitions found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("No exhibitions match your search for \"\(searchText)\"")
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
    
    private func updateFilteredExhibitions() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            filteredExhibitions = viewModel.exhibitions
            print("No search text - showing all \(viewModel.exhibitions.count) exhibitions")
            return
        }
        
        let searchQuery = searchText.lowercased()
        let filtered = viewModel.exhibitions.filter { exhibition in
            exhibition.displayTitle.lowercased().contains(searchQuery) ||
            exhibition.displayDescription.lowercased().contains(searchQuery) ||
            exhibition.displayDateRange.lowercased().contains(searchQuery)
        }
        
        // Debug info
        print("Search query: '\(searchQuery)'")
        print("Total exhibitions: \(viewModel.exhibitions.count)")
        print("Filtered exhibitions: \(filtered.count)")
        
        filteredExhibitions = filtered
    }
}

struct ExhibitionCardView: View {
    let exhibition: Exhibition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Large exhibition image
            AsyncImage(url: exhibition.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Exhibition details
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(exhibition.displayTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(exhibition.displayDateRange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                
                Text(exhibition.displayDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .clipped()
    }
}

#Preview {
    BrowseView()
}
