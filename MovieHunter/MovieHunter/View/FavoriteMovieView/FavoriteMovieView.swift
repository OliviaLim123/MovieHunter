//
//  WatchListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

// View to display all the favorite movies
import SwiftUI

struct FavoriteMovieView: View {
    @StateObject private var favoriteMovieVM = FavoriteMovieViewModel()
    var body: some View {
        NavigationView {
            Group {
                if favoriteMovieVM.favoriteMovies.isEmpty {
                    EmptyPlaceholderView(text: "Sorry, no movies are saved.", image: Image(systemName: "list.and.film"))
                } else {
                    List {
                        ForEach(favoriteMovieVM.favoriteMovies, id: \.id) { movie in
                            NavigationLink(destination: MovieDetailView(movieId: Int(movie.id), movieTitle: movie.title ?? "Unknown Title")) {
                                if let backdropURL = movie.backdropURL {
                                    FavoriteMovieImage(backdropURL: backdropURL)
                                        .frame(width: 61, height: 92)
                                        .cornerRadius(8)
                                        .shadow(radius: 4)
                                }
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
                        .onDelete(perform: favoriteMovieVM.deleteFavoriteMovie)
                    }
                }
            }
                    
            .navigationTitle("Favorite Movies")
            .onAppear {
                favoriteMovieVM.fetchFavoriteMovies()
            }
            .toolbar {
                EditButton()
            }
        }
    }
}

struct FavoriteMovieImage: View {
    let backdropURL: String
    @StateObject var imageLoader = ImageLoader()

    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .layoutPriority(-1)
            } else {
                ProgressView() // Show loading spinner while loading the image
            }
        }
        .onAppear {
            if let url = URL(string: backdropURL) {
                imageLoader.loadImage(with: url)
            } else {
                // Handle the case where URL is invalid
                print("Invalid URL: \(String(describing: backdropURL))")
            }
        }
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

#Preview {
    FavoriteMovieView()
}

