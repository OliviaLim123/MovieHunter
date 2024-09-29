//
//  NotificationView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI

struct NotificationView: View {
    @State private var selectedDate = Date()
    let movieTitle: String
    let imageURL: URL
    let movieRating: String
    let ratingText: String
    let notify = NotificationHandler()
    
    var body: some View {
        VStack {
            Text("Set a reminder to watch")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text(movieTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            } placeholder: {
                Image(systemName: "film")
                    .resizable()
                    .frame(width: 200)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            HStack {
                Text(movieRating)
                    .foregroundStyle(.yellow)
                Text(ratingText)
                    .font(.subheadline)
            }
            .padding(.bottom)
            VStack {
                Text("Select Date and Time")
                    .font(.headline)
                    .padding(.bottom, 5)
                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            Spacer()
            Button(action: {
                scheduleNotification()
            }) {
                Text("Schedule Notification")
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
        }
        .background(Color.white.ignoresSafeArea())
    }
    private func scheduleNotification() {
        notify.askPermission()
        notify.sendNotification(
            date: selectedDate,
            type: "time",
            title: "Hey, it's time to relax!",
            body: "Don't forget to watch \(movieTitle)")
    }
}

#Preview {
    NotificationView(movieTitle: Movie.mockSample.title, imageURL: Movie.mockSample.backdropURL, movieRating: Movie.mockSample.ratingText, ratingText: Movie.mockSample.scoreText)
}
