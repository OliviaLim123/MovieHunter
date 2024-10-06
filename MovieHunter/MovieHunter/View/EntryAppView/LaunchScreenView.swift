//
//  LogoView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import SwiftUI

// MARK: LAUNCH SCREEN VIEW
struct LaunchScreenView: View {
    
    // STATE PRIVATE PROPERTIES of LaunchScreenView
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    // BODY VIEW
    var body: some View {
        // Navigates to the TabView after LaunchScreenView if isActive
        if isActive {
            if self.status {
                TabView()
            } else {
                // Otherwise navigates to WelcomeView
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
        } else {
            VStack {
                appLogo
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    // Providing app logo ease in animation
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // Implement animation to the next view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    // APP LOGO VIEW
    var appLogo: some View {
        // Display the logo and application name
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
            Text("Movie Hunter")
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .font(.title)
        }
    }
}

// MARK: LAUNCH SCREEN PREVIEW
#Preview {
    LaunchScreenView()
}
