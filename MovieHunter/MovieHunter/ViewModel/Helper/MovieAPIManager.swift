//
//  MovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import Foundation

// MARK: MOVIE API MANAGER
class MovieAPIManager: MovieService {
    
    // STATIC PROPERTY
    static let shared = MovieAPIManager()
    private init() {}
    // PROPERTIES for API
    private let apiKey = "0d9467472a2bed765450187cee11d8ff"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    private let jsonDecoder = Decoder.jsonDecoder
    
    // METHOD for fetching movies from the given enpoint
    func fetchMovies(from endpoint: MovieListEndPoint) async throws -> [Movie] {
        // ERROR HANDLING if the endpoint is invalid
        guard let url = URL(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            throw MovieError.invalidEndpoint
        }
        let movieResponse: MovieResponse = try await self.loadURLAndDecode(url: url)
        return movieResponse.results
    }
    
    // METHOD for fetching movies by id
    func fetchMovie(id: Int) async throws -> Movie {
        // ERROR HANDLING if the endpoint is invalid
        guard let url = URL(string: "\(baseAPIURL)/movie/\(id)") else {
            throw MovieError.invalidEndpoint
        }
        return try await self.loadURLAndDecode(url: url, params: [ "append_to_response" : "videos,credits"])
    }
    
    // MERHOD for searching movie by query
    func searchMovie(query: String) async throws -> [Movie] {
        // ERROR HANDLING if the endpoint is invalid
        guard let url = URL(string: "\(baseAPIURL)/search/movie") else {
            throw MovieError.invalidEndpoint
        }
        // Load and decode the URL
        let movieResponse: MovieResponse = try await self.loadURLAndDecode(url: url, params: [
            "language" : "en-US",
            "include_adult" : "false",
            "region" : "US",
            "query" : query
            ])
        // Return the results
        return movieResponse.results
    }
    
    // PRIVATE METHOD for loading and decoding the JSON data from URL
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil) async throws -> D {
        // ERROR HANDLING if the endpoint is invalid
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw MovieError.invalidEndpoint
        }
        // Appending the query items
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        // ERROR HANDLING if the endpoint is invalid
        guard let finalURL = urlComponents.url else {
            throw MovieError.invalidEndpoint
        }
        let (data, response) = try await urlSession.data(from: finalURL)
        // ERROR HANDLING if the http response is invalid
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MovieError.invalidResponse
        }
        // Retrun decoded data
        return try self.jsonDecoder.decode(D.self, from: data)
    }
}
