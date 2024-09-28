//
//  MovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie]?
    @Published var isLoading = false
    @Published var error: NSError?
    
    private let movieService: MovieService
    
    init(movieService: MovieService = MovieAPIManager.shared) {
        self .movieService = movieService
    }
    
    func loadMovies(with endpoint: MovieListEndPoint) async {
        self.movies = nil
        self.isLoading = false
        
        do {
            let movies = try await self.movieService.fetchMovies(from: endpoint)
            self.isLoading = false
            self.movies = movies
        } catch {
            self.isLoading = false
            self.error = error as NSError
        }
    }
}
