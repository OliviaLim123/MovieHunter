//
//  NotificationHandler.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import Foundation
import UserNotifications
import FirebaseAuth

class NotificationHandler: NSObject,ObservableObject, UNUserNotificationCenterDelegate {
    @Published var notificationReceived = false
    @Published var notifications: [String] = []
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(date: Date, type: String, timeInterval: Double = 10, title: String, body: String, movieId: Int, movieTitle: String) {
        var trigger: UNNotificationTrigger?
        
        if type == "date" {
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        } else if type == "time" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["movieId": movieId, "movieTitle": movieTitle]
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let movieId = userInfo["movieId"] as? Int, let movieTitle = userInfo["movieTitle"] as? String {
            NotificationCenter.default.post(name: .notificationOpened, object: nil, userInfo: ["movieId": movieId, "movieTitle": movieTitle])
            let notificationMessage = "Reminder: \(movieTitle)"
            notifications.append(notificationMessage)
            self.notificationReceived = true
//            DispatchQueue.main.async {
//                self.notificationReceived = true
//            }
        }
        completionHandler()
    }
    
    func getUserReminders() -> [Reminders] {
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
extension Notification.Name {
    static let notificationOpened = Notification.Name("notificationOpened")
}
