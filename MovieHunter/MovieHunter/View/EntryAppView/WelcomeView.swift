//
//  WelcomeView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI

// MARK: WELCOME VIEW
struct WelcomeView: View {
    
    // STATE PRIVATE PROPERTIES of WelcomeView
    @State private var currentIndex = 0
    @State private var navigateToLogin = false
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    // PROPERTY for totalSteps
    let totalSteps = 3

    // BODY VIEW
    var body: some View {
        VStack {
            Spacer()
            
            // Display image for each step
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

            // Display text for each step
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

            // Button to next step
            Button {
                if currentIndex < totalSteps - 1 {
                    currentIndex += 1
                } else {
                    navigateToLogin = true
                }
            } label: {
                Text(currentIndex == totalSteps - 1 ? "Start Hunting!" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            // This button will navigate to the LoginView after reaching the last step
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                // When the view appears, it will observe the user status
                NotificationCenter.default.addObserver(forName: NSNotification.Name("status"), object: nil, queue: .main) { (_) in
                    self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                }
            }

            Spacer()

            // Display the page indicator
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

// MARK: WELCOME PREVIEW
#Preview {
    WelcomeView()
}
