//
//  Artwork.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Artwork: Codable, Identifiable, Equatable {
    let id: Int
    let title: String?
    let dated: String?
    let description: String?
    let labeltext: String?
    let primaryimageurl: String?
    let people: [Person]?
    
    // For tracking which exhibition this artwork was favorited from
    var exhibitionId: Int?
    var exhibitionTitle: String?
    
    // Computed properties for UI
    var displayTitle: String {
        title ?? "Untitled"
    }
    
    var displayArtist: String {
        if let people = people, !people.isEmpty {
            let names = people.compactMap { $0.effectiveName }.filter { !$0.isEmpty }
            return names.isEmpty ? "Unknown Artist" : names.joined(separator: ", ")
        }
        return "Unknown Artist"
    }
    
    var displayDate: String {
        dated ?? "Date unknown"
    }
    
    var displayDescription: String {
        if let desc = description, !desc.isEmpty {
            return desc
        } else if let label = labeltext, !label.isEmpty {
            return label
        } else {
            return "No description available"
        }
    }
    
    var imageURL: URL? {
        guard let urlString = primaryimageurl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
    
    // Custom coding keys to handle API response mapping
    enum CodingKeys: String, CodingKey {
        case id = "objectid"
        case title
        case dated
        case description
        case labeltext
        case primaryimageurl
        case people
    }
}
