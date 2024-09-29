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
    @Published private(set) var phase: DataFetchPhase<Movie?> = .empty
    var movie: Movie? {
        phase.value ?? nil
    }
    
    init(movieService: MovieService = MovieAPIManager.shared) {
        self.movieService = movieService
    }
    
    func loadMovie(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty

        do {
            let movie = try await self.movieService.fetchMovie(id: id)
            phase = .success(movie)
        } catch {
            phase = .failure(error)
        }
    }
}

