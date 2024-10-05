//
//  FavoriteMovieViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import CoreData
import SwiftUI
import FirebaseAuth

class FavoriteMovieViewModel: ObservableObject {
    @Published var favoriteMovies: [FavoriteMovie] = []

    private let persistenceController = PersistenceController.shared

    func fetchFavoriteMovies() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print ("No user is logged in")
            return
        }
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        //Filter favorite movies by the logged in user ID
        request.predicate = NSPredicate(format: "userId == %@", userId)

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
    
//    func saveFavoriteMovie(title: String, id: Int, backdropURL: String) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("No user is logged in")
//            return
//        }
//        
//        let context = persistenceController.container.viewContext
//        let favoriteMovie = FavoriteMovie(context: context)
//        favoriteMovie.title = title
//        favoriteMovie.id = Int64(id)
//        favoriteMovie.backdropURL = backdropURL
//        favoriteMovie.userId = userId
//        
//        persistenceController.saveContext()
//        fetchFavoriteMovies()
//    }
}
