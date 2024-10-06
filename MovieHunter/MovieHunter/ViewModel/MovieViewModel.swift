//
//  MovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

// MARK: MOVIE VIEW MODEL
class MovieViewModel: ObservableObject {
    
    // PUBLISHED PROPERTIES
    @Published var movies: [Movie]?
    @Published var isLoading = false
    @Published var error: NSError?
    
    // PRIVATE PROPERTY for MovieService
    private let movieService: MovieService
    
    // INIT METHOD to initialise the movieService
    init(movieService: MovieService = MovieAPIManager.shared) {
        self .movieService = movieService
    }
    
    // METHOD to load movies from end point asynchronously
    func loadMovies(with endpoint: MovieListEndPoint) async {
        // Reset the movies and the isLoading status
        self.movies = nil
        self.isLoading = false
        
        do {
            // Fetch the movies from end point through MovieService
            let movies = try await self.movieService.fetchMovies(from: endpoint)
            // Set the loading is false and store the movies
            self.isLoading = false
            self.movies = movies
        } catch {
            // ERROR HANDLING
            self.isLoading = false
            self.error = error as NSError
        }
    }
}
