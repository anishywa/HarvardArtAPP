//
//  Person.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Person: Codable {
    let name: String?
    let role: String?
    let displayname: String?
    
    var effectiveName: String? {
        if let displayname = displayname, !displayname.isEmpty {
            return displayname
        }
        return name
    }
}
