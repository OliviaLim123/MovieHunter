//
//  NotificationHandler.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import Foundation
import UserNotifications

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
            DispatchQueue.main.async {
                self.notificationReceived = true
            }
        }
        completionHandler()
    }
}
extension Notification.Name {
    static let notificationOpened = Notification.Name("notificationOpened")
}
