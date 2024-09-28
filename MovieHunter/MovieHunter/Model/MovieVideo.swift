//
//  MovieVideo.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

struct MovieVideoResponse: Decodable {
    let results: [MovieVideo]
}

struct MovieVideo: Decodable, Identifiable {
    let id: Int
    let key: String
    let name: String
    let site: String
    
    var youtubeURL: URL? {
        guard site == "YouTube" else {
            return nil
        }
        return URL(string: "https://youtube.com/watch?v=\(key)")
    }
}
