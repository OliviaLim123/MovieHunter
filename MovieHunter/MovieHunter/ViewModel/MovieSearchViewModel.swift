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
class MovieSearchViewModel: ObservableObject {
    
    @Published var query = ""
    @Published private(set) var phase: DataFetchPhase<[Movie]> = .empty
    
    private var cancellables = Set<AnyCancellable>()
    private let movieService: MovieService
    
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var movies: [Movie] {
        phase.value ?? []
    }
    
    
    init(movieService: MovieService = MovieAPIManager.shared) {
        self.movieService = movieService
    }
    
    func startObserve() {
        guard cancellables.isEmpty else { return }
        $query
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sink { [weak self]  _ in
                self?.phase = .empty
            }
            .store(in: &cancellables)
        $query
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { query in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.search(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) async {
        print("Searching for query: \(query)")
        if Task.isCancelled { return }
        phase = .empty
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        do {
            let movies = try await movieService.searchMovie(query: trimmedQuery)
            if Task.isCancelled { return }
            print("Movies found: \(movies)")
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .success(movies)
        } catch {
            print("Error: \(error.localizedDescription)")
            if Task.isCancelled { return }
            guard trimmedQuery == self.trimmedQuery else { return }
            phase = .failure(error)
        }
    }
}
