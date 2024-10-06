//
//  NotificationListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: REMINDER LIST VIEW
struct ReminderListView: View {
    
    // BINDING PROPERTY of Reminders
    @Binding var reminders: [Reminders]
    
    // PROPERTY of ReminderListView
    var onDismiss: () -> Void
    let notify = NotificationHandler()
    
    // COMPUTE PRIVATE PROPERTY to sort the reminders from the most recent
    private var sortedReminders: [Reminders] {
        reminders.sorted { $0.date > $1.date }
    }
    
    // BODY VIEW
    var body: some View {
        NavigationView {
            Group {
                // ERROR HANDLING if the reminder is empty
                if reminders.isEmpty {
                    VStack {
                        EmptyPlaceholderView(text: "Sorry, no reminders!", image: Image(systemName: "calendar.badge.exclamationmark"))
                    }
                } else {
                    // Display the sorted reminder list
                    List(sortedReminders) { reminder in
                        // Once it is clicked, it will navigate to the MovieDetailView
                        NavigationLink(destination: MovieDetailView(movieId: reminder.movieId, movieTitle: reminder.movieTitle)) {
                            VStack(alignment: .leading) {
                                // Display the movie title
                                Text(reminder.movieTitle)
                                    .font(.headline)
                                
                                // Display the reminder date
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
            // Once this view appears, it will load the user reminders
            .onAppear(perform: loadUserReminders)
            .onDisappear {
                // Notify when the view is dismissed
                onDismiss()
            }
        }
    }
    
    // PRIVATE FUNCTION to load current logged in user reminders
    private func loadUserReminders() {
        reminders = notify.getUserReminders()
    }
    
    // CLEAR BUTTON VIEW
    private var clearButton: some View {
        Button(action: clearReminders) {
            Text("Clear All")
                .foregroundColor(.red)
        }
    }
    
    // PRIVATE FUNCTION to clear the reminders
    private func clearReminders() {
        // ERROR HANDLING to check the current logged in user before clear the reminders
        guard let userId = Auth.auth().currentUser?.uid else {
            // DEBUG
            print("No user is logged in")
            return
        }
        
        // Fetch the saved notification from UserDefaults
        var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] ?? []
        savedNotifications.removeAll { notification in
            return notification["userId"] as? String == userId
        }
        
        // Clear and update the saved notification in UserDefaults
        UserDefaults.standard.removeObject(forKey: "savedNotifications")
        // Clear all reminders
        reminders.removeAll()
    }
    
    // PRIVATE FUNCTION to format the date into String type
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
