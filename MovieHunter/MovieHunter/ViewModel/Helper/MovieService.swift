//
//  MovieService.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import Foundation

// MARK: MOVIE SERVICE PROTOCOL
protocol MovieService {
    func fetchMovies(from endpoint: MovieListEndPoint) async throws -> [Movie]
    func fetchMovie(id: Int) async throws -> Movie
    func searchMovie(query: String) async throws -> [Movie]
}

// MARK: MOVIE LIST END POINT ENUM
enum MovieListEndPoint: String, CaseIterable, Identifiable {
    
    // PROPERTY of MovieListEndPoint
    var id: String { rawValue }
    // ENUM CASES
    case nowPlaying = "now_playing"
    case upcoming
    case topRated = "top_rated"
    case popular
    
    // COMPUTE PROPERTY for description
    var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Upcoming"
        case .topRated: return "Top Rated"
        case .popular: return "Popular"
        }
    }
}

// MARK: MOVIE ERROR ENUM
enum MovieError: Error, CustomNSError {
    
    // ENUM CASES of MovieError
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    // COMPUTE PROPERTY for localisedDescription in each error case
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
    
    // COMPUTE PROPERTY for error user info
    var errorUserInfo: [String:Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}
