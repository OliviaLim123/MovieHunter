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
    @State private var isShowingNotificationView = false
    let persistenceController = PersistenceController.shared
    
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
                        .foregroundStyle(isFavorite ? .red : .black)
                        .onTapGesture {
                            toggleFavorite(movie)
                        }
                }
                MovieDetailImage(imageURL: movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
                MovieDetailListView(movie: movie, selectedTrailerURL: $selectedTrailerURL)
                Button(action: {
                    isShowingNotificationView.toggle()
                }) {
                    Text("Set Reminder to Watch")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingNotificationView) {
                    NotificationView(movieTitle: movie.title)
                }
            }

        }
        .listStyle(.plain)
        .overlay(DataFetchPhaseOverlayView(phase: movieDetailVM.phase, retryAction: loadMovie))
        .sheet(item: $selectedTrailerURL) {
            SafariView(url: $0).edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            loadMovie()
            checkIfFavorite()
        }
    }
    private func loadMovie() {
        Task {
            await self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
    private func checkIfFavorite() {
        isFavorite = persistenceController.isFavorite(id: movieId)
    }

    private func toggleFavorite(_ movie: Movie) {
        if isFavorite {
            persistenceController.removeFavoriteMovie(id: movie.id)
        } else {
            persistenceController.addFavoriteMovie(id: movie.id, title: movie.title, year: movie.yearText, backdropURL: movie.backdropURL.absoluteString, rating: movie.ratingText)
        }
        isFavorite.toggle()
    }
}

extension URL: @retroactive Identifiable {
    public var id: Self { self }
}

#Preview {
    MovieDetailView(movieId: Movie.mockSample.id, movieTitle: "Titanic")
}
