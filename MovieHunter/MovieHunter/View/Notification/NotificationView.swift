//
//  NotificationView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: NOTIFICATION VIEW
struct NotificationView: View {
    
    // PROPERTIES of NotificationView
    let movieId: Int
    let movieTitle: String
    let imageURL: URL
    let movieRating: String
    let ratingText: String
    let notify = NotificationHandler()
    var onReminderSet: () -> Void
    
    // STATE PRIVATE PROPERTIES
    @State private var selectedDate = Date()
    @State private var showAlert = false
    // ENVIRONMENT PROPERTY for presentationMode
    @Environment(\.presentationMode) var presentationMode
    
    // BODY VIEW
    var body: some View {
        VStack {
            // Display set a reminder text
            Text("Set a reminder to watch")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            // Display the movie title
            Text(movieTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            // Display the image
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            } placeholder: {
                // ERROR HANDLING if there is no image
                Image(systemName: "film")
                    .resizable()
                    .frame(width: 200)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            
            HStack {
                // Display star rating
                Text(movieRating)
                    .foregroundStyle(.yellow)
                
                // Display score text out of 10
                Text(ratingText)
                    .font(.subheadline)
            }
            .padding(.bottom)
            
            VStack {
                // Display instruction to select date and time
                Text("Select Date and Time")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                // Display the date picker
                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            Spacer()
            
            // Button to schedule the notification
            Button {
                scheduleNotification()
            } label: {
                Text("Schedule Reminder")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            // Display alert to inform the user that schedule the reminder is successfully
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Schedule reminder is successful!"),
                    message: Text("You have scheduled a reminder to watch \(movieTitle)"),
                    dismissButton: .default(Text("OK")) {
                        onReminderSet()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // PRIVATE FUNCTION to schedule notification
    private func scheduleNotification() {
        // Ask the user's permission to send the notification
        notify.askPermission()
        // Send the notification with its detail
        notify.sendNotification(
            date: selectedDate,
            type: "date",
            title: "Hey, it's time to relax!",
            body: "Don't forget to watch \(movieTitle)",
            movieId: movieId,
            movieTitle: movieTitle  )
        // Save notification
        saveNotification()
        showAlert = true
        onReminderSet()
    }
    
    // PRIVATE FUNCTION to save the notification
    private func saveNotification() {
        // ERROR HANDLING to check the current logged in user before save the notification
        guard let userId = Auth.auth().currentUser?.uid else {
            // DEBUG
            print("No user is logged in")
            return
        }
        
        // Create the notification Data
        let notificationData: [String: Any] = [
            "movieId": movieId,
            "movieTitle": movieTitle,
            "date": selectedDate,
            "userId": userId
        ]
        
        // Save notification information to the UserDefaults
        var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [[String: Any]] ?? []
        savedNotifications.append(notificationData)
        UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
    }
}

// MARK: NOTIFICATION PREVIEW WITH MOCK SAMPLE
#Preview {
    NotificationView(movieId: Movie.mockSample.id, movieTitle: Movie.mockSample.title, imageURL: Movie.mockSample.backdropURL, movieRating: Movie.mockSample.ratingText, ratingText: Movie.mockSample.scoreText, onReminderSet: {})
}
