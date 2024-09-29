//
//  WatchListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

// View to display all the favorite movies
import SwiftUI

struct WatchListView: View {
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
                                HStack {
                                    Image(systemName: "film")
                                    VStack(alignment: .leading) {
                                        Text(movie.title ?? "Unknown Title")
                                            .font(.headline)
                                        Text(movie.yearText ?? "Unknown Year")
                                            .font(.subheadline)
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

#Preview {
    WatchListView()
}

