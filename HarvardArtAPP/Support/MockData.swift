//
//  MockData.swift
//  HarvardArtAPP
//
//  Created by Anish Sharma on 9/2/25.
//

import Foundation

#if DEBUG
extension Exhibition {
    static let mockExhibitions = [
        Exhibition(
            id: 1,
            title: "Van Gogh Exhibition: The Immersive Experience",
            description: "A comprehensive retrospective of Vincent van Gogh's masterpieces featuring over 200 paintings and drawings from museums around the world.",
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:53977_dynmc",
            begindate: "2023-03-15",
            enddate: "2024-01-30"
        ),
        Exhibition(
            id: 2,
            title: "Self-Portrait",
            description: "Exploring the tradition of self-portraiture from the Renaissance to contemporary art.",
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:53978_dynmc",
            begindate: "2023-06-01",
            enddate: "2023-12-15"
        ),
        Exhibition(
            id: 3,
            title: "The Potato Eaters",
            description: "Vincent van Gogh's famous painting and studies depicting rural life in 19th century Europe.",
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:53979_dynmc",
            begindate: "2023-09-10",
            enddate: "2024-03-20"
        )
    ]
}

extension Artwork {
    static let mockArtworks = [
        Artwork(
            id: 1,
            title: "Starry Night",
            dated: "1889",
            description: "Vincent van Gogh's masterful depiction of a swirling night sky reflecting on a village below. Painted with characteristic bold brushstrokes and vivid colors.",
            labeltext: nil,
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:54001_dynmc",
            people: [Person(name: "Vincent van Gogh", role: "artist", displayname: "Vincent van Gogh")]
        ),
        Artwork(
            id: 2,
            title: "Self-Portrait",
            dated: "1889",
            description: "One of van Gogh's many self-portraits, showcasing his distinctive style and emotional intensity.",
            labeltext: nil,
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:54002_dynmc",
            people: [Person(name: "Vincent van Gogh", role: "artist", displayname: "Vincent van Gogh")]
        ),
        Artwork(
            id: 3,
            title: "The Potato Eaters",
            dated: "1885",
            description: "A masterpiece depicting a family of peasants sharing a meal by lamplight, representing van Gogh's commitment to portraying the lives of ordinary people.",
            labeltext: nil,
            primaryimageurl: "https://nrs.harvard.edu/urn-3:HUAM:54003_dynmc",
            people: [Person(name: "Vincent van Gogh", role: "artist", displayname: "Vincent van Gogh")]
        )
    ]
}

// Mock responses for development and testing
struct MockAPIResponse {
    static func exhibitions() -> APIResponse<Exhibition> {
        return APIResponse(
            info: PageInfo(
                totalrecords: 3,
                totalrecordsperquery: 20,
                page: 1,
                pages: 1,
                next: nil,
                prev: nil
            ),
            records: Exhibition.mockExhibitions
        )
    }
    
    static func artworks() -> APIResponse<Artwork> {
        return APIResponse(
            info: PageInfo(
                totalrecords: 3,
                totalrecordsperquery: 20,
                page: 1,
                pages: 1,
                next: nil,
                prev: nil
            ),
            records: Artwork.mockArtworks
        )
    }
}
#endif
