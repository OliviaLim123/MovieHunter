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
    @StateObject private var notificationHandler = NotificationHandler()
    @State private var hasNotification = false
    @State private var showNotificationList = false
    @State private var reminders: [Reminders] = []
    let notify = NotificationHandler()
    
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                bellIcon
            }
        }
        .onAppear {
            loadReminders()  // Load reminders when the view appears
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationOpened)) { _ in
            hasNotification = false  // Reset notification badge after it is opened
        }
        .sheet(isPresented: $showNotificationList) {
            ReminderListView(reminders: $reminders) {  // Pass reminders as Binding
                hasNotification = false  // Reset badge when ReminderListView is dismissed
            }
        }
    }
    
    private var bellIcon: some View {
        ZStack {
            Image(systemName: "bell")
                .foregroundColor(.primary)
                .onTapGesture {
                    showNotificationList = true  // Show the notification list when tapped
                }
            if hasNotification {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 8, y: -8)  // Adjusted positioning of the red badge
            }
        }
        .onAppear {
            notificationHandler.askPermission()  // Ask for notification permissions
            loadUserReminders()
        }
        .onReceive(notificationHandler.$notificationReceived) { received in
            hasNotification = received  // Update the notification state when received
        }
    }
        
    private func loadMovies(invalidateCache: Bool) {
        Task {
            await movieHomeVM.loadMoviesFromAllEndpoints(invalidateCache: invalidateCache)
        }
    }
    
    private func loadReminders() {
        if let savedReminders = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] {
            reminders = savedReminders.compactMap { dict in
                if let movieId = dict["movieId"] as? Int,
                   let movieTitle = dict["movieTitle"] as? String,
                   let date = dict["date"] as? Date {
                    return Reminders(movieId: movieId, movieTitle: movieTitle, date: date)
                }
                return nil
            }
            if !reminders.isEmpty {
                hasNotification = true
            }
        }
    }
    
    private func loadUserReminders() {
        let userReminders = notify.getUserReminders()  // Fetch the current user's reminders
        reminders = userReminders  // Update the local reminders
        
        // If there are any reminders, set the bell icon to show a red badge
        hasNotification = !userReminders.isEmpty
    }
}


#Preview {
    NavigationStack {
        MovieHomeView()
    }
}
