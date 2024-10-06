//
//  MovieDetailViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import SwiftUI

@MainActor
// MARK: MOVIE DETAIL VIEW MODEL
class MovieDetailViewModel: ObservableObject {
    
    // PRIVATE PROPERTY for MovieService
    private let movieService: MovieService
    // PUBLISHED PRIVATE PROPERTY for data fetch phase
    @Published private(set) var phase: DataFetchPhase<Movie?> = .empty
    // COMPUTE PROPERTY for movie object
    var movie: Movie? {
        phase.value ?? nil
    }
    
    // INIT METHOD to initialise the MovieService
    init(movieService: MovieService = MovieAPIManager.shared) {
        self.movieService = movieService
    }
    
    // METHOD to load movie based on the specific ID asynchronously
    func loadMovie(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            // Fetch the movie based on the movie id
            let movie = try await self.movieService.fetchMovie(id: id)
            // Mark the phase as success after successfully fetched movie
            phase = .success(movie)
        } catch {
            // ERROR HANDLING by marking the phase as failure if error occurs
            phase = .failure(error)
        }
    }
}

