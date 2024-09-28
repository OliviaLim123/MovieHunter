//
//  MovieSection.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

struct MovieSection: Identifiable {
    let id = UUID()
    let movies: [Movie]
    let endpoint: MovieListEndPoint
    var title: String {
        endpoint.description
    }
    
    var thumbnailType: MovieThumbnailType {
        endpoint.thumnailType
    }
}

fileprivate extension MovieListEndPoint {
    var thumnailType: MovieThumbnailType {
        switch self {
        case .nowPlaying:
            return .poster()
        default:
            return .backdrop
        }
    }
}
