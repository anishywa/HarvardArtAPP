//
//  Classification.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Classification: Codable, Identifiable {
    let id: Int
    let name: String?
    let objectcount: Int?
    
    var displayName: String {
        name ?? "Unknown Medium"
    }
    
    var displayCount: String {
        if let count = objectcount {
            return "\(count) objects"
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "classificationid"
        case name
        case objectcount
    }
}
