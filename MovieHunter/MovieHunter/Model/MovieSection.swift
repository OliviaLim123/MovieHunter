//
//  MovieSection.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

// MARK: MOVIE SECTION
struct MovieSection: Identifiable {
    
    // PROPERTIES of MovieSection
    let id = UUID()
    let movies: [Movie]
    let endpoint: MovieListEndPoint
    
    // COMPUTE PROPERTY for title
    var title: String {
        endpoint.description
    }
    
    // COMPUTE PROPERTY for movie thumbnail type
    var thumbnailType: MovieThumbnailType {
        endpoint.thumnailType
    }
}

// MARK: MOVIE LIST END POINT PRIVATE EXTENSION
fileprivate extension MovieListEndPoint {
    
    // COMPUTE PROPERTY to return the movie thumnail type 
    var thumnailType: MovieThumbnailType {
        switch self {
        case .nowPlaying:
            return .poster()
        default:
            return .backdrop
        }
    }
}
