//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject private var movieDetailVM = MovieDetailViewModel()
//    let movie: Movie
    
    var body: some View {
        VStack {
            // Display loading animation until movie is loaded
            if let movie = movieDetailVM.movie {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(movie.title)
                                .font(.title)
                                .padding(.horizontal)
                                .fontWeight(.bold)
                            //ADD THE HEART SYMBOL
                        }
                        MovieDetailImage (imageURL: movie.backdropURL)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowInsets(EdgeInsets())
                    }
                }
            } else {
                LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                    self.movieDetailVM.loadMovie(id: self.movieId)
                }
            }
        }
        .onAppear {
            self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
}

#Preview {
    MovieDetailView(movieId: Movie.mockSample.id)
}
