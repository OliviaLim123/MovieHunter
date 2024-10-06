//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

// MARK: MOVIE DETAIL VIEW
struct MovieDetailView: View {
    
    // STATE OBJECT for view models
    @StateObject private var movieDetailVM = MovieDetailViewModel()
    @StateObject private var favoriteMovieVM = FavoriteMovieViewModel()
    
    // STATE PROPERTIES of MovieDetailView
    @State private var selectedTrailerURL: URL?
    @State private var isFavorite: Bool = false
    @State private var isShowingNotificationView = false
    @State private var isReminderSet = false
    
    // PROPERTIES of MovieDetilView
    let movieId: Int
    let movieTitle: String
    let persistenceController = PersistenceController.shared
        
    // BODY VIEW
    var body: some View {
        List {
            if let movie = movieDetailVM.movie {
                HStack {
                    // Display the movie title
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    
                    // Display the favourite button
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 30))
                        .foregroundStyle(isFavorite ? .red : .black)
                        .onTapGesture {
                            toggleFavorite(movie)
                        }
                }
                
                // Display the Movie Image
                MovieDetailImage(imageURL: movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
                // Display the movie trailers
                MovieDetailListView(movie: movie, selectedTrailerURL: $selectedTrailerURL)
                
                // Button to set the reminder of the specific movie
                Button {
                    isShowingNotificationView.toggle()
                } label: {
                    Text(isReminderSet ? "Reminder Set!" : "Set Reminder to Watch")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isReminderSet ? Color.blue.opacity(0.5): Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isReminderSet)
                // Prepare the Notification View after set the reminder
                .sheet(isPresented: $isShowingNotificationView) {
                    NotificationView(movieId: movie.id, movieTitle: movie.title, imageURL: movie.backdropURL, movieRating: movie.ratingText, ratingText: movie.scoreText, onReminderSet : {
                        isReminderSet = true
                    })
                }
            }
        }
        .listStyle(.plain)
        .overlay(DataFetchPhaseOverlayView(phase: movieDetailVM.phase, retryAction: loadMovie))
        // Navigate to the YouTube View from Safari
        .sheet(item: $selectedTrailerURL) {
            SafariView(url: $0).edgesIgnoringSafeArea(.bottom)
        }
        // Once this view appears, it will load movie and check favorite status
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
    
    // PRIVATE FUNCTION to load the movie
    private func loadMovie() {
        Task {
            await self.movieDetailVM.loadMovie(id: self.movieId)
        }
    }
    
    // PRIVATE FUNCTION to check the favourite status based on the current logged in user
    private func checkIfFavorite() {
        let userId = Auth.auth().currentUser?.uid
        isFavorite = favoriteMovieVM.favoriteMovies.contains { $0.id == Int64(movieId) && $0.userId == userId }
    }

    // PRIVATE FUNCTION to toggle the favourite button
    private func toggleFavorite(_ movie: Movie) {
        if isFavorite {
            // If it is not favorite, it will be removed
            persistenceController.removeFavoriteMovie(id: movie.id)
        } else {
            // If it is favourite, it will be added to the list
            persistenceController.addFavoriteMovie(id: movie.id, title: movie.title, year: movie.yearText, backdropURL: movie.backdropURL.absoluteString, rating: movie.ratingText)
        }
        isFavorite.toggle()
    }
}

// MARK: URL EXTENSION
extension URL: @retroactive Identifiable {
    
    // PROPERTY of url
    public var id: Self { self }
}

// MARK: MOVIE DETAIL PREVIEW
#Preview {
    MovieDetailView(movieId: Movie.mockSample.id, movieTitle: "Titanic")
}
