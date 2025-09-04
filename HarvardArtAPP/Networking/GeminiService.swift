//
//  GeminiService.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
    private var apiKey: String {
        // Read API key from Secrets.plist
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["GEMINI_API_KEY"] as? String else {
            print("⚠️ Warning: GEMINI_API_KEY not found in Secrets.plist")
            return ""
        }
        return key
    }
    
    private init() {}
    
    @MainActor
    func generateArtworkOverview(for artwork: Artwork, exhibition: Exhibition) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        let prompt = createPrompt(for: artwork, exhibition: exhibition)
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt)
                    ]
                )
            ]
        )
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw GeminiError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Gemini API Error: \(errorData)")
            }
            throw GeminiError.apiError(httpResponse.statusCode)
        }
        
        do {
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let firstCandidate = geminiResponse.candidates.first,
                  let firstPart = firstCandidate.content.parts.first else {
                throw GeminiError.noContent
            }
            
            return firstPart.text
        } catch {
            throw GeminiError.decodingError(error)
        }
    }
    
    private func createPrompt(for artwork: Artwork, exhibition: Exhibition) -> String {
        var prompt = """
        Please provide a concise historical overview of this artwork in exactly 1 paragraph (4-6 sentences). Focus on the most important historical context, artistic significance, and one interesting fact. Keep it engaging and informative for museum visitors.
        
        Artwork Details:
        - Title: \(artwork.displayTitle)
        - Artist: \(artwork.displayArtist)
        - Date: \(artwork.displayDate)
        """
        
        if !artwork.displayDescription.isEmpty && artwork.displayDescription != "No description available" {
            prompt += "\n- Description: \(artwork.displayDescription)"
        }
        
        if !exhibition.displayTitle.isEmpty && exhibition.displayTitle != "Search Results" {
            prompt += "\n- Exhibition: \(exhibition.displayTitle)"
        }
        
        prompt += """
        
        Provide only the most essential historical context, key artistic techniques or style, cultural significance, and one compelling fact about this piece. Write in a single, well-structured paragraph that flows naturally. Make it accessible and engaging for general museum visitors.
        """
        
        return prompt
    }
}

// MARK: - Data Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Error Types
enum GeminiError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case encodingError(Error)
    case decodingError(Error)
    case invalidResponse
    case apiError(Int)
    case noContent
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key not found. Please add GEMINI_API_KEY to Secrets.plist"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let statusCode):
            return "API error with status code: \(statusCode)"
        case .noContent:
            return "No content received from API"
        }
    }
}
