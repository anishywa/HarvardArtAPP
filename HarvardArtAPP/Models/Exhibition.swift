//
//  Exhibition.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Exhibition: Codable, Identifiable {
    let id: Int
    let title: String?
    let description: String?
    let primaryimageurl: String?
    let begindate: String?
    let enddate: String?
    
    // Computed properties for UI
    var displayTitle: String {
        title ?? "Unknown Exhibition"
    }
    
    var displayDescription: String {
        description ?? "No description available"
    }
    
    var displayDateRange: String {
        let begin = begindate ?? ""
        let end = enddate ?? ""
        
        if !begin.isEmpty && !end.isEmpty {
            return "\(begin) - \(end)"
        } else if !begin.isEmpty {
            return "From \(begin)"
        } else if !end.isEmpty {
            return "Until \(end)"
        } else {
            return "Date unknown"
        }
    }
    
    var imageURL: URL? {
        guard let urlString = primaryimageurl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
