//
//  ContentView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesStore = FavoritesStore.shared
    
    var body: some View {
        TabView {
            NavigationStack {
                BrowseView()
            }
            .tabItem {
                Image(systemName: "building.columns")
                Text("Browse")
            }
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Favorites")
            }
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
        }
        .environmentObject(favoritesStore)
    }
}

#Preview {
    ContentView()
}
