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
    
    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailVM.isLoading, error: self.movieDetailVM.error) {
                self.movieDetailVM.loadMovie(id: self.movieId)
            }
            
            if movieDetailVM.movie != nil {
                MovieDetailListView(movie: self.movieDetailVM.movie!)
            }
//            } else {
//                LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
//                    self.movieDetailVM.loadMovie(id: self.movieId)
//                }
//            }
        }
        .onAppear {
            self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
}

#Preview {
    MovieDetailView(movieId: Movie.mockSample.id)
}
