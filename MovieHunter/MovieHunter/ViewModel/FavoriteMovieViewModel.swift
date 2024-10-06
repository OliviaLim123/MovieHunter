//
//  FavoriteMovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import CoreData
import SwiftUI
import FirebaseAuth

// MARK: FAVORITE MOVIE VIEW MODEL
class FavoriteMovieViewModel: ObservableObject {
    
    // PUBLISHED PROPERTY of FavouriteMoviewViewModel
    @Published var favoriteMovies: [FavoriteMovie] = []
    // PRIVATE PROPERTY of FavouriteMoviewViewModel
    private let persistenceController = PersistenceController.shared

    // METHOD to fetch the favourite movies from Core Data
    func fetchFavoriteMovies() {
        // ERROR HANDLING to check the current user logged in before fetching
        guard let userId = Auth.auth().currentUser?.uid else {
            print ("No user is logged in")
            return
        }
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        // Filter favorite movies by the logged in user ID
        request.predicate = NSPredicate(format: "userId == %@", userId)
        do {
            favoriteMovies = try context.fetch(request)
        } catch {
            // ERROR HANDLING if the fetching process is failed
            print("Failed to fetch favorite movies: \(error)")
        }
    }

    // METHOD to delete favorite movie from specific index set in Core Data
    func deleteFavoriteMovie(at indexSet: IndexSet) {
        let context = persistenceController.container.viewContext
        indexSet.forEach { index in
            let movie = favoriteMovies[index]
            // Delete the favourite movie at specific index
            context.delete(movie)
        }
        // Save the updated context after deleting process
        persistenceController.saveContext()
        // Refresh the list after deletion
        fetchFavoriteMovies()
    }
}
