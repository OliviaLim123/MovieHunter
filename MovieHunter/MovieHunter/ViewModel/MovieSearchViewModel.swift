//
//  MovieSearchViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI
import Combine
import Foundation

@MainActor
// MARK: MOVIE SEARCH VIEW MODEL
class MovieSearchViewModel: ObservableObject {
    
    // PUBLISHED PROPERTIES of MovieSearchViewModel
    @Published var query = ""
    @Published private(set) var phase: DataFetchPhase<[Movie]> = .empty
    
    // PRIVATE PROPERTIES of MovieSearchViewModel
    private var cancellables = Set<AnyCancellable>()
    private let movieService: MovieService
    
    // COMPUTE PROPERTY to trimmed the query characters
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // COMPUTE PROPERTY for movie array
    var movies: [Movie] {
        phase.value ?? []
    }
    
    // INIT METHOD to initialise the MovieService
    init(movieService: MovieService = MovieAPIManager.shared) {
        self.movieService = movieService
    }
    
    // METHOD to start observing the changes in the query string and handle search accordingly
    func startObserve() {
        // ERROR HANDLING
        guard cancellables.isEmpty else { return }
        
        // Observe the query and check if it's empty or just whitespace
        $query
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sink { [weak self]  _ in
                self?.phase = .empty
            }
            .store(in: &cancellables)
        
        // Observe the query when it contains non-empty values (non-whitespace)
        $query
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        // Apply debounce to avoid making requests too frequently
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { query in
                Task { [weak self] in
                    // ERROR HANDLING
                    guard let self = self else { return }
                    // Perform the search with the trimmed query
                    await self.search(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    // METHOD to perform an asynchronous search using the query string
    func search(query: String) async {
        // DEBUG
        print("Searching for query: \(query)")
        if Task.isCancelled { return }
        phase = .empty
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ERROR HANDLING to stop if the query is empty after trimming
        guard !trimmedQuery.isEmpty else { return }
        
        do {
            // Call the movie service to search for movies using the trimmed query
            let movies = try await movieService.searchMovie(query: trimmedQuery)
            if Task.isCancelled { return }
            // DEBUG
            print("Movies found: \(movies)")
            // ERROR HANDLING to ensure that the trimmed query hasn't changed while the search was ongoing
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .success(movies)
        } catch {
            // DEBUG
            print("Error: \(error.localizedDescription)")
            if Task.isCancelled { return }
            // ERROR HANDLING to ensure the trimmed query hasn't changed while handling the error
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .failure(error)
        }
    }
}
