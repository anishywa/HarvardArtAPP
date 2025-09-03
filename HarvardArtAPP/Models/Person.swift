//
//  Person.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Person: Codable, Identifiable, Equatable {
    let id: Int?
    let name: String?
    let role: String?
    let displayname: String?
    let objectcount: Int?
    let birthdate: String?
    let deathdate: String?
    let birthplace: String?
    
    var effectiveName: String {
        if let displayname = displayname, !displayname.isEmpty {
            return displayname
        }
        return name ?? "Unknown Artist"
    }
    
    var displayCount: String {
        if let count = objectcount {
            return "\(count) objects"
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "personid"
        case name
        case role
        case displayname
        case objectcount
        case birthdate
        case deathdate
        case birthplace
    }
}
