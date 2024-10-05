//
//  WelcomeView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI

struct WelcomeView: View {
    @State private var currentIndex = 0
    let totalSteps = 3 // You can adjust this based on how many screens you have
    @State private var navigateToLogin = false

    var body: some View {
        VStack {
            Spacer()
            
            // Image Section
            if currentIndex == 0 {
                LottieView(name: Constants.discoverMovieAnimation, loopMode: .loop, animationSpeed: 1.0, retryAction: {})
                    .frame(height: 400)
            } else if currentIndex == 1 {
                LottieView(name: Constants.reminderAnimation, loopMode: .loop, animationSpeed: 1.0, retryAction: {})
                    .frame(height: 400)
            } else if currentIndex == 2 {
                LottieView(name: Constants.movieAnimation, loopMode: .loop, animationSpeed: 1.0, retryAction: {})
                    .frame(height: 400)
            }
            
            Spacer()

            // Text Section
            VStack(spacing: 10) {
                Text(currentIndex == 0 ? "Discover Movies" : currentIndex == 1 ? "Add to Reminder" : "Personal Movie Collections")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(currentIndex == 0 ? "Find the latest and trending movies across all genres." :
                        currentIndex == 1 ? "Easily add reminders to your personalised list." :
                        "Save and showcase the films that truly speak to you.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()

            // "Next" Button
            Button(action: {
                if currentIndex < totalSteps - 1 {
                    currentIndex += 1
                } else {
                    navigateToLogin = true
                }
            }) {
                Text(currentIndex == totalSteps - 1 ? "Start Hunting!" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }

            Spacer()

            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<Int(totalSteps), id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentIndex == index ? Color.black : Color.gray.opacity(0.5))
                }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    WelcomeView()
}
