//
//  WelcomeView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
             Text("Welcome to Movie Hunter!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom,40)
            LottieView(name: Constants.welcomeAnimation, loopMode: .loop, animationSpeed: 1.0, retryAction: {})
                .frame(width: 400, height: 400)
                .padding(.bottom, 40)
            Text("Let's discover your favourite movies and create a notification to remind yourself to watch them!")
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            Button {
                //Navigate to the login View
            }label: {
                HStack {
                    Image(systemName: "play.circle")
                    Text("Start Hunting!")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
