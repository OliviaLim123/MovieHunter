//
//  Persistence.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import CoreData
import FirebaseAuth

// MARK: PERSISTENCE CONTROLLER
class PersistenceController {
    
    // STATIC PROPERTY
    static let shared = PersistenceController()
    // PROPERTY for managing the Core Data container
    let container: NSPersistentContainer

    // INIT METHOD for initialise the Core data with a container name
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataMovieHunter")
        // Set the store's URL as /dev/null
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        // Load the persistent store
        container.loadPersistentStores { (storeDescription, error) in
            // ERROR HANDLING when storing
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // METHOD to save the context if there are any changes
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // ERROR HANDLING when saving context
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // METHOD to add a favourite movie for the current logged-in user
    func addFavoriteMovie(id: Int, title: String, year: String, backdropURL: String, rating: String) {
        // Checking a user is logged in before saving
        guard let userId = Auth.auth().currentUser?.uid else {
            // DEBUG
            print("No user is logged in")
            return
        }
        let context = container.viewContext
        let favoriteMovie = FavoriteMovie(context: context)
        // Assign values to the favorite movie entity based on its attribute
        favoriteMovie.id = Int64(id)
        favoriteMovie.title = title
        favoriteMovie.yearText = year
        favoriteMovie.backdropURL = backdropURL
        favoriteMovie.ratingText = rating
        favoriteMovie.userId = userId
        // Save the context to persist the favourite movie
        saveContext()
    }

    // METHOD to remove a favorite movie based on its ID and current logged-in user
    func removeFavoriteMovie(id: Int) {
        // Checking a user is logged in before removing
        guard let userId = Auth.auth().currentUser?.uid else {
            // DEBUG
            print("No user is logged in")
            return
        }
        let context = container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        // Fetch only the movie with the matching ID and user ID
        request.predicate = NSPredicate(format: "id == %d AND userId == %@", id, userId)
        // If the movies exist in the user's favorites, detele it
        if let favoriteMovie = try? context.fetch(request).first {
            context.delete(favoriteMovie)
            // Save the updated context after removing
            saveContext()
        }
    }

    // METHOD to check if a movie is in the user's favourites list
    func isFavorite(id: Int) -> Bool {
        // Checking a user is logged in
        guard let userId = Auth.auth().currentUser?.uid else {
            return false
        }
        let context = container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        // Fetch the movie with the matching ID and user ID
        request.predicate = NSPredicate(format: "id == %d AND userId == %@", id, userId)
        // Return true if the movie exists in the user's favourites
        // Return false if the movie doesn't exist in the user's favourites
        return (try? context.fetch(request).first) != nil
    }
}
