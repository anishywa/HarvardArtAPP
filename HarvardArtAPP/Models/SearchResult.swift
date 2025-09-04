//
//  SearchResult.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

enum SearchResult: Identifiable {
    case artwork(Artwork)
    case exhibition(Exhibition)
    case artist(Person)
    case medium(Classification)
    
    var id: String {
        switch self {
        case .artwork(let artwork):
            return "artwork_\(artwork.id)"
        case .exhibition(let exhibition):
            return "exhibition_\(exhibition.id)"
        case .artist(let person):
            // Use a more robust ID generation for artists
            if let personId = person.id {
                return "artist_\(personId)"
            } else {
                // Fallback to name-based ID if person ID is nil
                return "artist_\(person.effectiveName.hashValue)"
            }
        case .medium(let classification):
            return "medium_\(classification.id)"
        }
    }
    
    var title: String {
        switch self {
        case .artwork(let artwork):
            return artwork.displayTitle
        case .exhibition(let exhibition):
            return exhibition.displayTitle
        case .artist(let person):
            return person.effectiveName
        case .medium(let classification):
            return classification.displayName
        }
    }
    
    var subtitle: String {
        switch self {
        case .artwork(let artwork):
            return artwork.displayArtist
        case .exhibition(let exhibition):
            return exhibition.displayDateRange
        case .artist(let person):
            return person.displayCount
        case .medium(let classification):
            return classification.displayCount
        }
    }
    
    var description: String {
        switch self {
        case .artwork(let artwork):
            return artwork.displayDescription
        case .exhibition(let exhibition):
            return exhibition.displayDescription
        case .artist(let person):
            return person.role ?? ""
        case .medium(let classification):
            return "Medium/Classification"
        }
    }
    
    var imageURL: URL? {
        switch self {
        case .artwork(let artwork):
            return artwork.imageURL
        case .exhibition(let exhibition):
            return exhibition.imageURL
        case .artist, .medium:
            return nil // No images for artists and mediums in this API
        }
    }
}
