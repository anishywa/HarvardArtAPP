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
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar at the top
            searchBar
            
            ZStack {
                if viewModel.exhibitions.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    exhibitionsList
                }
                
                if viewModel.isLoading && viewModel.exhibitions.isEmpty {
                    ProgressView("Loading exhibitions...")
                }
            }
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.refreshExhibitions()
        }
        .task {
            await viewModel.loadExhibitions()
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 12)
            
            TextField("Search for an exhibition", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .disabled(true) // For now, just visual - search functionality in Search tab
            
            Spacer()
        }
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private var exhibitionsList: some View {
        List {
            ForEach(viewModel.exhibitions) { exhibition in
                NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                    ExhibitionCardView(exhibition: exhibition)
                }
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
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Exhibition details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(exhibition.displayTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(exhibition.displayDateRange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(exhibition.displayDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.top, 12)
            .padding(.horizontal, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    BrowseView()
}
