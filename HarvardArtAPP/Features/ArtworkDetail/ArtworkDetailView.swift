//
//  ArtworkDetailView.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork
    let exhibition: Exhibition
    @EnvironmentObject private var favoritesStore: FavoritesStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Large artwork image
                artworkImage
                
                // Artwork details
                artworkDetails
                
                Spacer(minLength: 100) // Extra space at bottom
            }
        }
        .navigationTitle(artwork.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private var artworkImage: some View {
        AsyncImage(url: artwork.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1.2, contentMode: .fit)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
    
    private var artworkDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and heart
            HStack(alignment: .top) {
                Text(artwork.displayTitle)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoritesStore.toggleFavorite(artwork: artwork, fromExhibition: exhibition)
                    }
                }) {
                    Image(systemName: favoritesStore.isFavorite(artworkId: artwork.id) ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(favoritesStore.isFavorite(artworkId: artwork.id) ? .red : .primary)
                }
            }
            
            // Artist information
            if !artwork.displayArtist.isEmpty && artwork.displayArtist != "Unknown Artist" {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Artist:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(formatArtistName(artwork.displayArtist))
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
            
            // Date information
            if !artwork.displayDate.isEmpty && artwork.displayDate != "Date unknown" {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(artwork.displayDate)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
            
            // Medium information (if available from artwork data)
            if let medium = extractMediumFromDescription() {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medium:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(medium)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
            
            // Dimensions (if available from artwork data)
            if let dimensions = extractDimensionsFromDescription() {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dimensions:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(dimensions)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
            
            // Description
            if !artwork.displayDescription.isEmpty && artwork.displayDescription != "No description available" {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(artwork.displayDescription)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Helper function to extract medium information from description or other fields
    private func extractMediumFromDescription() -> String? {
        // This is a simplified extraction - in a real app you might have dedicated fields
        let description = artwork.displayDescription.lowercased()
        
        if description.contains("oil on canvas") {
            return "Oil on canvas"
        } else if description.contains("watercolor") {
            return "Watercolor"
        } else if description.contains("bronze") {
            return "Bronze"
        } else if description.contains("marble") {
            return "Marble"
        } else if description.contains("photograph") {
            return "Photograph"
        }
        
        return nil
    }
    
    // Helper function to extract dimensions from description
    private func extractDimensionsFromDescription() -> String? {
        // This is a simplified extraction - in a real app you might have dedicated fields
        let description = artwork.displayDescription
        
        // Look for patterns like "29 x 36 1/4 in." or similar
        let pattern = #"\d+\.?\d*\s*[x×]\s*\d+\.?\d*\s*(?:\d+/\d+)?\s*(?:in\.|inches|cm|centimeters)"#
        
        if let range = description.range(of: pattern, options: .regularExpression, range: nil, locale: nil) {
            return String(description[range])
        }
        
        return nil
    }
    
    // Helper function to format artist name with dates
    private func formatArtistName(_ artistName: String) -> String {
        // If we have people data with dates, use that
        if let people = artwork.people, !people.isEmpty {
            let firstPerson = people[0]
            if let displayName = firstPerson.displayname, !displayName.isEmpty {
                return displayName
            }
        }
        
        // Otherwise return the basic artist name
        return artistName
    }
}

#Preview {
    let artwork = Artwork(
        id: 1,
        title: "Starry Night",
        dated: "1889",
        description: "Vincent van Gogh's Starry Night is a masterful depiction of a night sky filled with swirling energy, luminous stars, and a tranquil village below. Oil on canvas, 29 x 36 1/4 in.",
        labeltext: nil,
        primaryimageurl: "https://example.com/starry-night.jpg",
        people: [Person(id: 1, name: "Vincent van Gogh", role: "artist", displayname: "Vincent van Gogh (1853-1890)", objectcount: 100, birthdate: "1853", deathdate: "1890", birthplace: "Groot-Zundert, Netherlands")],
        exhibitionId: 1,
        exhibitionTitle: "Van Gogh Exhibition"
    )
    
    let exhibition = Exhibition(
        id: 1,
        title: "Van Gogh Exhibition",
        description: "A comprehensive look at the work of Vincent van Gogh",
        primaryimageurl: nil,
        begindate: "2023",
        enddate: "2024"
    )
    
    NavigationView {
        ArtworkDetailView(artwork: artwork, exhibition: exhibition)
            .environmentObject(FavoritesStore.shared)
    }
}
