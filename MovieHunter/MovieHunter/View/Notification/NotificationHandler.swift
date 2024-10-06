//
//  NotificationHandler.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import Foundation
import UserNotifications
import FirebaseAuth

// MARK: NOTIFICATION HANDLER
class NotificationHandler: NSObject,ObservableObject, UNUserNotificationCenterDelegate {
    
    // PUBLISHED PROPERTIES
    @Published var notificationReceived = false
    @Published var notifications: [String] = []
    
    // OVERRIDE INIT METHOD
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // METHOD to ask the user permission before sending the notification
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                // DEBUG
                print("Access granted!")
            } else if let error = error {
                // DEBUG and ERROR HANDLING
                print(error.localizedDescription)
            }
        }
    }
    
    // METHOD to send notification based on the time interval or scheduled date
    func sendNotification(date: Date, type: String, timeInterval: Double = 10, title: String, body: String, movieId: Int, movieTitle: String) {
        var trigger: UNNotificationTrigger?
        
        if type == "date" {
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        } else if type == "time" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        }
        
        let content = UNMutableNotificationContent()
        // Assign the title, body, sound, and user info to the content
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["movieId": movieId, "movieTitle": movieTitle]
        
        // Create the request and add it to the notification center
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // METHOD for managing the user interaction with a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Check if the userInfo contains a movieId and movieTitle
        if let movieId = userInfo["movieId"] as? Int, let movieTitle = userInfo["movieTitle"] as? String {
            NotificationCenter.default.post(name: .notificationOpened, object: nil, userInfo: ["movieId": movieId, "movieTitle": movieTitle])
            // Add a message about the reminder to the local notifications list
            let notificationMessage = "Reminder: \(movieTitle)"
            notifications.append(notificationMessage)
            self.notificationReceived = true
        }
        completionHandler()
    }
    
    // METHOD to get the current logged in user reminders
    func getUserReminders() -> [Reminders] {
        // ERROR HANDLING to check the current logged in user before get the reminders
        guard let userId = Auth.auth().currentUser?.uid else {
            // DEBUG
            print("No user is logged in")
            return []
        }
        
        // Fetch the saved notifications from UserDefaults, or use an empty array if none are found
        let savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] ?? []
        
        // Filter reminders by the current user's userId
        let userReminders = savedNotifications.filter { notification in
            return notification["userId"] as? String == userId
        }
        
        // Convert the filtered dictionary data back into Reminders objects
        let reminders = userReminders.compactMap { data -> Reminders? in
            // ERROR HANDLING
            guard let movieId = data["movieId"] as? Int,
                  let movieTitle = data["movieTitle"] as? String,
                  let date = data["date"] as? Date else { return nil }
            return Reminders(movieId: movieId, movieTitle: movieTitle, date: date)
        }
        // Return the reminders
        return reminders
    }
}

// MARK: NOTIFICATION.NAME EXTENSION
extension Notification.Name {
    static let notificationOpened = Notification.Name("notificationOpened")
}
