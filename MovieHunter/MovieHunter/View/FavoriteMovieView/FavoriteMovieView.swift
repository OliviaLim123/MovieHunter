//
//  WatchListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

// MARK: FAVORITE MOVIE VIEW
struct FavoriteMovieView: View {
    
    // STATE OBJECT of Favorite Movie View Model
    @StateObject private var favoriteMovieVM = FavoriteMovieViewModel()
    
    // BODY VIEW
    var body: some View {
        NavigationView {
            Group {
                // Display the placeholder if it is empty
                if favoriteMovieVM.favoriteMovies.isEmpty {
                    EmptyPlaceholderView(text: "Sorry, no movies are saved.", image: Image(systemName: "list.and.film"))
                } else {
                    // If it is not empty, display favorite movie list
                    List {
                        ForEach(favoriteMovieVM.favoriteMovies, id: \.id) { movie in
                            // Once it is clicked, it will navigate to the specific MovieDetailView
                            NavigationLink(destination: MovieDetailView(movieId: Int(movie.id), movieTitle: movie.title ?? "Unknown Title")) {
                                // Display the image for each favorite movie
                                if let backdropURL = movie.backdropURL {
                                    FavoriteMovieImage(backdropURL: backdropURL)
                                        .frame(width: 61, height: 80)
                                        .cornerRadius(8)
                                        .shadow(radius: 4)
                                }
                                // Display the movie title, release year, and rating star
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(movie.title ?? "Unknown Title")
                                            .font(.headline)
                                        Text(movie.yearText ?? "Unknown Year")
                                            .font(.subheadline)
                                        Text(movie.ratingText ?? "No Rating")
                                            .foregroundStyle(.yellow)
                                    }
                                }
                            }
                        }
                        // This code allows the user to delete a specific favorite movie
                        .onDelete(perform: favoriteMovieVM.deleteFavoriteMovie)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorite Movies")
            // Once this view appears, it will fetch all the favorite movies from the Core Data
            .onAppear {
                favoriteMovieVM.fetchFavoriteMovies()
            }
        }
    }
}

// MARK: FAVORITE MOVIE IMAGE
struct FavoriteMovieImage: View {
    
    // PROPERTY for backdropURL
    let backdropURL: String
    // STATE OBJECT for image loader
    @StateObject var imageLoader = ImageLoader()

    // BODY VIEW
    var body: some View {
        ZStack {
            // Background color
            Color.gray.opacity(0.3)
            
            // Display the image from image loader
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .layoutPriority(-1)
            } else {
                // Show loading spinner while loading the image
                ProgressView()
            }
        }
        .onAppear {
            // Once this view appears, it will load the image based on the url
            if let url = URL(string: backdropURL) {
                imageLoader.loadImage(with: url)
            } else {
                // ERROR HANDLING and DEBUG
                print("Invalid URL: \(String(describing: backdropURL))")
            }
        }
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

// MARK: FAVORITE MOVIE PREVIEW
#Preview {
    FavoriteMovieView()
}

