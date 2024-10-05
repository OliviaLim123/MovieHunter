//
//  NotificationListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI
import FirebaseAuth

struct ReminderListView: View {
    @Binding var reminders: [Reminders]   // Accept reminders as a parameter
    var onDismiss: () -> Void
    private var sortedReminders: [Reminders] {
        reminders.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if reminders.isEmpty {
                    VStack {
                        EmptyPlaceholderView(text: "Sorry, no reminders!", image: Image(systemName: "calendar.badge.exclamationmark"))
                    }
                } else {
                    List(sortedReminders) { reminder in
                        NavigationLink(destination: MovieDetailView(movieId: reminder.movieId, movieTitle: reminder.movieTitle)) {
                            VStack(alignment: .leading) {
                                Text(reminder.movieTitle)
                                    .font(.headline)
                                Text("\(formattedDate(reminder.date))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Reminders")
            .navigationBarItems(trailing: clearButton)
            .onAppear(perform: loadUserReminders)
            .onDisappear {
                onDismiss()  // Notify when the view is dismissed
            }
        }
    }
    private func loadUserReminders() {
        reminders = loadUserReminders()  // Load reminders for the current user
    }
    
    private var clearButton: some View {
        Button(action: clearReminders) {
            Text("Clear All")
                .foregroundColor(.red)  // Color for the clear button
        }
    }
    
    private func clearReminders() {
        // Clear reminders and update UserDefaults
        reminders.removeAll()  // This will work because reminders is a Binding
        UserDefaults.standard.removeObject(forKey: "savedNotifications")  // Clear saved notifications in UserDefaults
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    func loadUserReminders() -> [Reminders] {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return []
        }
        
        let savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] ?? []
        
        // Filter reminders by the current user's userId
        let userReminders = savedNotifications.filter { notification in
            return notification["userId"] as? String == userId
        }
        
        // Convert the filtered dictionary data back into Reminders objects
        let reminders = userReminders.compactMap { data -> Reminders? in
            guard let movieId = data["movieId"] as? Int,
                  let movieTitle = data["movieTitle"] as? String,
                  let date = data["date"] as? Date else { return nil }
            
            return Reminders(movieId: movieId, movieTitle: movieTitle, date: date)
        }
        
        return reminders
    }
}
