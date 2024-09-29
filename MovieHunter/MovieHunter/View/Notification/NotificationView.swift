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
    NotificationView(movieTitle: "Minion")
}
