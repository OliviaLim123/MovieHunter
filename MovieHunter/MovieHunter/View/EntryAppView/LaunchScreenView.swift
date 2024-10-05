//
//  LogoView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import SwiftUI

//LAUNCH SCREEN VIEW Struct
struct LaunchScreenView: View {
    
    //STATE variable to track whether the view is active
    @State private var isActive = false
    //STATE variable to manage the size of the view
    @State private var size = 0.8
    //STATE variable to control the opacity of the view
    @State private var opacity = 0.5
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    //LAUNCH SCREEN VIEW
    var body: some View {
        //Navigates to the APP ENTRY VIEW after the LAUNCH SCREEN
        if isActive {
            if self.status {
                TabView()
            } else {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
//            WelcomeView()
        } else {
            VStack {
                appLogo
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    //Providing APP LOGO ANIMATION
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                //ANIMATION to the next view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    //APP LOGO Appearance
    var appLogo: some View {
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

#Preview {
    LaunchScreenView()
}
