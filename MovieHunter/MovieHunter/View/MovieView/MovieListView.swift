//
//  MovieListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

@MainActor
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
                        MovieThumbnailCarouselView(title: "Now Playing", movies: nowPlaying.movies!, thumbnailType: .poster())
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            Task {
                                await self.nowPlaying.loadMovies(with: .nowPlaying)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
                LazyVStack {
                    if upcoming.movies != nil {
                        MovieThumbnailCarouselView(title: "Upcoming", movies: upcoming.movies!, thumbnailType: .backdrop)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            Task {
                                await self.nowPlaying.loadMovies(with: .upcoming)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                
                LazyVStack {
                    if topRated.movies != nil {
                        MovieThumbnailCarouselView(title: "Top Rated", movies: topRated.movies!, thumbnailType: .backdrop)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            Task {
                               await self.topRated.loadMovies(with: .topRated)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                
                LazyVStack {
                    if popular.movies != nil {
                        MovieThumbnailCarouselView(title: "Popular", movies: popular.movies!, thumbnailType: .backdrop)
                    } else {
                        LottieView(name: Constants.loadingAnimation, loopMode: .loop, animationSpeed: 1.0) {
                            Task {
                                await self.popular.loadMovies(with: .popular)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
            }
            .navigationTitle("Movie Hunter List")
        }
        .onAppear {
            Task {
                await self.nowPlaying.loadMovies(with: .nowPlaying)
                await self.upcoming.loadMovies(with: .upcoming)
                await self.topRated.loadMovies(with: .topRated)
                await self.popular.loadMovies(with: .popular)
            }
        }
    }
}

#Preview {
    MovieListView()
}
