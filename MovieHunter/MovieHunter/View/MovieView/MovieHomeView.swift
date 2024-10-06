//
//  MovieListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

@MainActor
// MARK: MOVIE HOME VIEW
struct MovieHomeView: View {
    
    // STATE OBJECT for view models
    @StateObject private var movieHomeVM = MovieHomeViewModel()
    @StateObject private var notificationHandler = NotificationHandler()
    @StateObject private var profileVM = ProfileViewModel()
    
    // STATE PROPERTIES of Movie Home View
    @State private var hasNotification = false
    @State private var showNotificationList = false
    @State private var reminders: [Reminders] = []
    
    // BODY VIEW
    var body: some View {
        List {
            // Display the Movie Thumbnail Carousel View
            ForEach(movieHomeVM.sections) {
                MovieThumbnailCarouselView(title: $0.title, movies: $0.movies, thumbnailType: $0.thumbnailType)
            }
            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowSeparator(.hidden)
        }
        //Load the movies asynchronously when the view is displayed (without invalidating the cache)
        .task {
            loadMovies(invalidateCache: false)
        }
        // Enable pull-to-refresh functionality to reload movies, invalidating the cache this time
        .refreshable {
            loadMovies(invalidateCache: true)
        }
        .overlay(DataFetchPhaseOverlayView(phase: movieHomeVM.phase, retryAction: {
            // Retry to load the movies
            loadMovies(invalidateCache: true)
        }))
        .listStyle(.plain)
        .navigationTitle("Movie Hunter Lists")
        // Enable the tool bar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Display the bell icon
                bellIcon
            }
        }
        // Once this view appears, it will load reminders, load user theme preferences, and update color scheme
        .onAppear {
            loadReminders()
            profileVM.loadUserThemePreference()
            profileVM.updateColorScheme()
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationOpened)) { _ in
            // Reset notification badge after it is opened
            hasNotification = false
        }
        .sheet(isPresented: $showNotificationList) {
            ReminderListView(reminders: $reminders) {
                // Reset badge when ReminderListView is dismissed
                hasNotification = false
            }
        }
    }
    
    // BELL ICON VIEW
    private var bellIcon: some View {
        ZStack {
            // Diplay the bell icon
            Image(systemName: "bell")
                .foregroundColor(.primary)
                .onTapGesture {
                    // Show the notification list when tapped
                    showNotificationList = true
                }
            
            // If there is notification inside it, red circle will be shown in the bell icon
            if hasNotification {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 8, y: -8)
            }
        }
        // Once this bell icon appears, it will ask the permission and load the user reminders
        .onAppear {
            notificationHandler.askPermission()
            loadUserReminders()
        }
        .onReceive(notificationHandler.$notificationReceived) { received in
            // Update the notification state when received
            hasNotification = received
        }
    }
        
    // PRIVATE FUNCTION to load movies from the cache
    private func loadMovies(invalidateCache: Bool) {
        Task {
            await movieHomeVM.loadMoviesFromAllEndpoints(invalidateCache: invalidateCache)
        }
    }
    
    // PRIVATE FUNCTION to load reminders
    private func loadReminders() {
        // Fetch the saved reminders from the user default
        if let savedReminders = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] {
            reminders = savedReminders.compactMap { dict in
                if let movieId = dict["movieId"] as? Int,
                   let movieTitle = dict["movieTitle"] as? String,
                   let date = dict["date"] as? Date {
                    // Create the reminders
                    return Reminders(movieId: movieId, movieTitle: movieTitle, date: date)
                }
                return nil
            }
            // If the reminder is not empty, it means has the notification
            if !reminders.isEmpty {
                hasNotification = true
            }
        }
    }
    
    // PRIVATE FUNCTION to load user reminders
    private func loadUserReminders() {
        // Fetch the current user's reminders
        let userReminders = notificationHandler.getUserReminders()
        // Update the local reminders
        reminders = userReminders
        // If there are any reminders, set the bell icon to show a red circle
        hasNotification = !userReminders.isEmpty
    }
}

// MARK: MOVIE HOME PREVIEW
#Preview {
    NavigationStack {
        MovieHomeView()
    }
}
