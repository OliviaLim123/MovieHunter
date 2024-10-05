//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct MovieDetailView: View {
    let movieId: Int
    let movieTitle: String
    @StateObject private var movieDetailVM = MovieDetailViewModel()
    @State private var selectedTrailerURL: URL?
    @State private var isFavorite: Bool = false
    @State private var isShowingNotificationView = false
    @State private var isReminderSet = false
    let persistenceController = PersistenceController.shared
    @StateObject private var favoriteMovieVM = FavoriteMovieViewModel()
        
    
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
                    Text(isReminderSet ? "Reminder Set!" : "Set Reminder to Watch")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isReminderSet ? Color.blue.opacity(0.5): Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isReminderSet)
                .sheet(isPresented: $isShowingNotificationView) {
                    NotificationView(movieId: movie.id, movieTitle: movie.title, imageURL: movie.backdropURL, movieRating: movie.ratingText, ratingText: movie.scoreText, onReminderSet : {
                        isReminderSet = true
                    })
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
            NotificationCenter.default.addObserver(forName: .notificationOpened, object: nil, queue: .main) { _ in
                // Reset the reminder state when notification is opened
                isReminderSet = false
            }
        }
        .onDisappear {
            // Prevent memory leaks
            NotificationCenter.default.removeObserver(self, name: .notificationOpened, object: nil)
        }
    }
    private func loadMovie() {
        Task {
            await self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
    private func checkIfFavorite() {
        let userId = Auth.auth().currentUser?.uid
        isFavorite = favoriteMovieVM.favoriteMovies.contains { $0.id == Int64(movieId) && $0.userId == userId }
//        isFavorite = persistenceController.isFavorite(id: movieId)
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
