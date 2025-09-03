//
//  APIClient.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let baseURL = "https://api.harvardartmuseums.org"
    private let session = URLSession.shared
    private var apiKey: String
    
    init() {
        // Load API key from Secrets.plist
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["HAM_API_KEY"] as? String {
            self.apiKey = key
        } else {
            self.apiKey = "" // Will fail requests but app won't crash
            print("⚠️ API Key not found in Secrets.plist")
        }
    }
    
    // MARK: - Exhibitions
    
    func fetchExhibitions(page: Int = 1, size: Int = 20) async throws -> APIResponse<Exhibition> {
        let endpoint = "/exhibition"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    // MARK: - Artworks
    
    func fetchArtworksInExhibition(exhibitionId: Int, page: Int = 1, size: Int = 20) async throws -> APIResponse<Artwork> {
        let endpoint = "/object"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "exhibition", value: String(exhibitionId)),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "hasimage", value: "1")
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    func searchArtworks(query: String, page: Int = 1, size: Int = 20) async throws -> APIResponse<Artwork> {
        let endpoint = "/object"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "hasimage", value: "1")
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    // MARK: - Generic Request Handler
    
    private func performRequest<T: Codable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }
        
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not found in Secrets.plist"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
