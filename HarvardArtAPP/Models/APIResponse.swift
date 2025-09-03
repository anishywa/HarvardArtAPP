//
//  APIResponse.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let info: PageInfo
    let records: [T]
}

struct PageInfo: Codable {
    let totalrecords: Int
    let totalrecordsperquery: Int
    let page: Int
    let pages: Int
    let next: String?
    let prev: String?
    
    var hasNextPage: Bool {
        page < pages
    }
    
    var hasPreviousPage: Bool {
        page > 1
    }
}
