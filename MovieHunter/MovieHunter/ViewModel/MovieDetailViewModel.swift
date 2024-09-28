//
//  MovieDetailViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import SwiftUI

@MainActor
class MovieDetailViewModel: ObservableObject {
    private let movieService: MovieService
    @Published var movie: Movie?
    @Published var isLoading: Bool = false
    @Published var error: NSError?
    
    init(movieService: MovieService = MovieAPIManager.shared) {
        self.movieService = movieService
    }
    
    func loadMovie(id: Int) async {
        self.movie = nil
        self.isLoading = true
        do {
            let movie = try await self.movieService.fetchMovie(id: id)
            self.movie = movie
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.error = error as NSError
        }
    }
}

