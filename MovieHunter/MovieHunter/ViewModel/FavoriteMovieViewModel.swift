//
//  FavoriteMovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import CoreData
import SwiftUI

class FavoriteMovieViewModel: ObservableObject {
    @Published var favoriteMovies: [FavoriteMovie] = []

    private let persistenceController = PersistenceController.shared

    func fetchFavoriteMovies() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()

        do {
            favoriteMovies = try context.fetch(request)
        } catch {
            print("Failed to fetch favorite movies: \(error)")
        }
    }

    func deleteFavoriteMovie(at indexSet: IndexSet) {
        let context = persistenceController.container.viewContext
        indexSet.forEach { index in
            let movie = favoriteMovies[index]
            context.delete(movie)
        }

        persistenceController.saveContext()
        fetchFavoriteMovies() // Refresh the list after deletion
    }
}
