//
//  Persistence.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataMovieHunter")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // Save favorite movie
    func addFavoriteMovie(id: Int, title: String, year: String, backdropURL: String, rating: String) {
        let context = container.viewContext
        let favoriteMovie = FavoriteMovie(context: context)
        favoriteMovie.id = Int64(id)
        favoriteMovie.title = title
        favoriteMovie.yearText = year
        favoriteMovie.backdropURL = backdropURL
        favoriteMovie.ratingText = rating
        
        saveContext()
    }

    // Remove favorite movie
    func removeFavoriteMovie(id: Int) {
        let context = container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        if let favoriteMovie = try? context.fetch(request).first {
            context.delete(favoriteMovie)
            saveContext()
        }
    }

    // Check if movie is a favorite
    func isFavorite(id: Int) -> Bool {
        let context = container.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        return (try? context.fetch(request).first) != nil
    }
}
