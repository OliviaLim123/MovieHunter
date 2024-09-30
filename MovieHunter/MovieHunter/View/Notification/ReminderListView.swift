//
//  NotificationListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI

struct ReminderListView: View {
    @Binding var reminders: [Reminders]   // Accept reminders as a parameter
    var onDismiss: () -> Void
    private var sortedReminders: [Reminders] {
        reminders.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            List(sortedReminders) { reminder in
                VStack(alignment: .leading) {
                    Text(reminder.movieTitle)
                        .font(.headline)
                    Text("\(formattedDate(reminder.date))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Your Reminders")
            .navigationBarItems(trailing: clearButton)
            .onDisappear {
                onDismiss()  // Notify when the view is dismissed
            }
        }
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
}
