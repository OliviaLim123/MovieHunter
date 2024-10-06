//
//  MovieVideo.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

// MARK: MOVIE VIDEO RESPONSE
struct MovieVideoResponse: Decodable {
    
    // PROPERTY of MovieVideoResponse
    let results: [MovieVideo]
}

// MARK: MOVIE VIDEO MODEL
struct MovieVideo: Decodable, Identifiable {
    
    // PROPERTIES of MovieVideo
    let id: String
    let key: String
    let name: String
    let site: String
    
    // COMPUTE PROPERTY for YouTube URL trailer
    var youtubeURL: URL? {
        // ERROR HANDLING when the site is not YouTube
        guard site == "YouTube" else {
            return nil
        }
        return URL(string: "https://youtube.com/watch?v=\(key)")
    }
}
