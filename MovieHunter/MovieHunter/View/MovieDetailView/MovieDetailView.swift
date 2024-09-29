//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import Foundation
import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    let movieTitle: String
    @StateObject private var movieDetailVM = MovieDetailViewModel()
    @State private var selectedTrailerURL: URL?
    @State private var isFavorite: Bool = false
    
    var body: some View {
        List {
            if let movie = movieDetailVM.movie {
                HStack {
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 30))
                }
                MovieDetailImage(imageURL: movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
                MovieDetailListView(movie: movie, selectedTrailerURL: $selectedTrailerURL)
            }

        }
        .listStyle(.plain)
//        .navigationTitle(movieTitle)
        .overlay(DataFetchPhaseOverlayView(phase: movieDetailVM.phase, retryAction: loadMovie))
        .sheet(item: $selectedTrailerURL) {
            SafariView(url: $0).edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            loadMovie()
        }
    }
    private func loadMovie() {
        Task {
            await self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: Self { self }
}

#Preview {
    MovieDetailView(movieId: Movie.mockSample.id, movieTitle: "Titanic")
}
