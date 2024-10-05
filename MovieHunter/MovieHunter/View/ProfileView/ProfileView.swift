//
//  ProfileView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var navigateToLogin: Bool = false
    var body: some View {
        VStack {
            Text("Logged successfully")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.black.opacity(0.7))
            
            Button {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                navigateToLogin = true
            } label :{
                Text("Log out")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 25)
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    ProfileView()
}
