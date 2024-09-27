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
    
    func loadMovies(with endpoint: MovieListEndPoint) {
        self.movies = nil
        self.isLoading = false
        self.movieService.fetchMovies(from: endpoint) { [weak self] (result) in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.movies = response.results
            case .failure(let error):
                self.error = error as NSError
            }
        }
    }
}
