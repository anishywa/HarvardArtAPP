//
//  Exhibition.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

struct Exhibition: Codable, Identifiable, Equatable {
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
            let formattedBegin = formatDateToMonthYear(begin)
            let formattedEnd = formatDateToMonthYear(end)
            return "\(formattedBegin) - \(formattedEnd)"
        } else if !begin.isEmpty {
            let formattedBegin = formatDateToMonthYear(begin)
            return "From \(formattedBegin)"
        } else if !end.isEmpty {
            let formattedEnd = formatDateToMonthYear(end)
            return "Until \(formattedEnd)"
        } else {
            return "Date unknown"
        }
    }
    
    private func formatDateToMonthYear(_ dateString: String) -> String {
        // Create formatters for common patterns
        let dateFormatPatterns = [
            "yyyy-MM-dd",
            "yyyy/MM/dd", 
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "yyyy",
            "MM/yyyy",
            "yyyy-MM"
        ]
        
        let allFormatters = dateFormatPatterns.map { pattern -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = pattern
            return formatter
        }
        
        // Try to parse the date with various formatters
        for formatter in allFormatters {
            if let date = formatter.date(from: dateString) {
                // Format as abbreviated month and year (e.g., "Sept. 1999")
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMM. yyyy"
                let formattedString = outputFormatter.string(from: date)
                
                // Special case: Remove period after "May" since it's already short
                if formattedString.hasPrefix("May.") {
                    return formattedString.replacingOccurrences(of: "May.", with: "May")
                }
                
                return formattedString
            }
        }
        
        // If we can't parse it, try to extract year at least
        if let year = extractYear(from: dateString) {
            return year
        }
        
        // Fallback to original string if all parsing fails
        return dateString
    }
    
    private func extractYear(from dateString: String) -> String? {
        // Look for a 4-digit year in the string
        let yearRegex = try? NSRegularExpression(pattern: "\\b(19|20)\\d{2}\\b")
        let range = NSRange(location: 0, length: dateString.count)
        
        if let match = yearRegex?.firstMatch(in: dateString, range: range) {
            let yearRange = Range(match.range, in: dateString)
            if let yearRange = yearRange {
                return String(dateString[yearRange])
            }
        }
        
        return nil
    }
    
    var imageURL: URL? {
        guard let urlString = primaryimageurl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
