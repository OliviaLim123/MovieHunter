//
//  MovieHomeViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

@MainActor
// MARK: MOVIE HOME VIEW MODEL
class MovieHomeViewModel: ObservableObject {
    // PUBLISHED PRIVATE PROPERTY for data fetch phase
    @Published private(set) var phase: DataFetchPhase<[MovieSection]> = .empty
    // PRIVATE PROPERTY for MovieService
    private let movieService: MovieService = MovieAPIManager.shared
    // COMPUTE PROPERTY of MovieSection
    var sections: [MovieSection] {
        phase.value ?? []
    }
    
    // MERHOD to load movies from all endpoints asynchronously
    func loadMoviesFromAllEndpoints(invalidateCache: Bool) async {
        if Task.isCancelled { return }
        if case .success = phase, !invalidateCache {
            return
        }
        phase = .empty
        do {
            // Fetch the movies from the end points and mark as success
            let sections = try await fetchMoviesFromEndpoints()
            if Task.isCancelled { return }
            phase = .success(sections)
        } catch {
            // ERROR HANDLING by marking the phase as failure if error occurs
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
    // PRIVATE METHOD to fetch movie from multiple endpoints simultaneously
    private func fetchMoviesFromEndpoints(_ endpoints: [MovieListEndPoint] = MovieListEndPoint.allCases) async throws -> [MovieSection] {
        let results: [Result<MovieSection, Error>] = await withTaskGroup(of: Result<MovieSection, Error>.self){ group in
            for endpoint in endpoints {
                // For each endpoint, add a task to the group
                group.addTask { await self.fetchMoviesFromEndpoint(endpoint)}
            }
            var results = [Result<MovieSection, Error>]()
            // Wait for all tasks to complete and collect the results
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        // Variable to store successful movie section results
        var movieSections = [MovieSection]()
        // Variable to store errors
        var errors = [Error]()
        
        // Process the results: separate successes from errors
        results.forEach { result in
            switch result {
            case .success(let movieSection):
                movieSections.append(movieSection)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        // If all tasks resulted in failure, throw the first encountered error
        if errors.count == results.count, let error = errors.first {
            throw error
        }
        // Return the movie sections sorted by the endpoint's `sortIndex`
        return movieSections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    // PRIVATE METHOD to fetch movies from a single endpoint
    private func fetchMoviesFromEndpoint(_ endpoint: MovieListEndPoint) async -> Result<MovieSection,Error> {
        do {
            // Call the movie service to fetch movies for the given endpoint
            let movies = try await movieService.fetchMovies(from: endpoint)
            // Return a successful result with the fetched movies and associated endpoint
            return .success(.init(movies: movies, endpoint: endpoint))
        } catch {
            // ERROR HANDLING by returning a failure result with error
            return .failure(error)
        }
    }
}

// MARK: MOVIE LIST END POINT PRIVATE EXTENSION
fileprivate extension MovieListEndPoint {
    // Assign a sort index for each endpoint to maintain consistent ordering
    var sortIndex: Int {
        switch self {
        case .nowPlaying:
            return 0
        case .upcoming:
            return 1
        case .topRated:
            return 2
        case .popular:
            return 3
        }
    }
}
