//
//  SearchMovieView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

struct SearchMovieView: View {
    @ObservedObject var movieSearchVM = MovieSearchViewModel()
    
    var body: some View {
        ScrollView {
            SearchBarView(placeholder: "Search movies", text: self.$movieSearchVM.query)
                .padding(.horizontal, 10)
            
            LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                Task {
                    await self.movieSearchVM.search(query: self.movieSearchVM.query)
                }
            }
            
            if self.movieSearchVM.movies != nil {
                if let movies = self.movieSearchVM.movies {
                    ForEach(movies) { movie in
                        NavigationLink(destination: MovieDetailView(movieId: movie.id, movieTitle: movie.title)) {
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                Text(movie.yearText)
                            }
                        }
                    }
                } else {
                    Text("No movies are found.")
                }
            }
        }
        .onAppear {
            self.movieSearchVM.startObserve()
        }
        .navigationBarTitle("Search Movies")
    }
}

#Preview {
    NavigationView {
        SearchMovieView()
    }
}
