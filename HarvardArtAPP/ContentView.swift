//
//  ContentView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesStore = FavoritesStore.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BrowseView()
            }
            .tabItem {
                Image(systemName: "building.columns")
                Text("Browse")
            }
            .tag(0)
            
            NavigationStack {
                FavoritesView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Favorites")
            }
            .tag(1)
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(2)
        }
        .environmentObject(favoritesStore)
        .environmentObject(appearanceManager)
        .preferredColorScheme(appearanceManager.currentMode.colorScheme)
    }
}

#Preview {
    ContentView()
}
