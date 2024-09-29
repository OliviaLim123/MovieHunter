//
//  MovieListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

@MainActor
struct MovieHomeView: View {
    
    @StateObject private var movieHomeVM = MovieHomeViewModel()
    
    var body: some View {
        List {
            ForEach(movieHomeVM.sections) {
                MovieThumbnailCarouselView(title: $0.title, movies: $0.movies, thumbnailType: $0.thumbnailType)
            }
            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowSeparator(.hidden)
        }
        .task {
            loadMovies(invalidateCache: false)
        }
        .refreshable {
            loadMovies(invalidateCache: true)
        }
        .overlay(DataFetchPhaseOverlayView(phase: movieHomeVM.phase, retryAction: {
            loadMovies(invalidateCache: true)
        }))
        .listStyle(.plain)
        .navigationTitle("Movie Hunter Lists")
    }
    
    private func loadMovies(invalidateCache: Bool) {
        Task {
            await movieHomeVM.loadMoviesFromAllEndpoints(invalidateCache: invalidateCache)
        }
    }
}


#Preview {
    NavigationView {
        MovieHomeView()
    }
}
