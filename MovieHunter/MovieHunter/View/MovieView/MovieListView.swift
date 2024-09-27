//
//  MovieListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject private var nowPlaying = MovieViewModel()
    @ObservedObject private var upcoming = MovieViewModel()
    @ObservedObject private var topRated = MovieViewModel()
    @ObservedObject private var popular = MovieViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    if nowPlaying.movies != nil {
                        MoviePosterListView(title: "Now Playing", movies: nowPlaying.movies!)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            self.nowPlaying.loadMovies(with: .nowPlaying)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
                LazyVStack {
                    if upcoming.movies != nil {
                        MovieHorizontalView(title: "Upcoming", movies: upcoming.movies!)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            self.nowPlaying.loadMovies(with: .upcoming)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                
                LazyVStack {
                    if topRated.movies != nil {
                        MovieHorizontalView(title: "Top Rated", movies: topRated.movies!)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            self.topRated.loadMovies(with: .topRated)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                
                LazyVStack {
                    if popular.movies != nil {
                        MovieHorizontalView(title: "Popular", movies: popular.movies!)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            self.popular.loadMovies(with: .popular)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
            }
            .navigationBarTitle("Movie Hunter List")
        }
        .onAppear {
            self.nowPlaying.loadMovies(with: .nowPlaying)
            self.upcoming.loadMovies(with: .upcoming)
            self.topRated.loadMovies(with: .topRated)
            self.popular.loadMovies(with: .popular)
        }
    }
}

#Preview {
    MovieListView()
}
