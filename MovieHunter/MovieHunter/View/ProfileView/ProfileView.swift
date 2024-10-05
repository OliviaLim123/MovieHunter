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
    @State private var email: String? = nil
    @State private var accountCreationDate: String? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var successMessage: String = ""
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        VStack {
//            if let userEmail = email {
            if let userEmail = email, let creationDate = accountCreationDate {
                VStack {
                    Text("Welcome back!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 20)
                    Text(getInitial(from: userEmail))
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                        .clipShape(Circle())
                        .padding(.bottom, 20)
                    Text("\(userEmail)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    Text("Account Created on \(creationDate)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
            } else {
                Text("Fetching user info...")
                    .font(.title)
            }
            
            Spacer()
            Toggle(isOn: profileVM.$isDarkMode) {
                HStack {
                    Image(systemName: profileVM.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(profileVM.isDarkMode ? .gray : .yellow)
                                .font(.system(size: 24))
                    Text("Enable Night Mode")
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 25)
            .onChange(of: profileVM.isDarkMode) { newValue, _ in
                profileVM.updateColorScheme()
            }
            Spacer()
            
            Button {
                resetPassword()
            } label: {
                Text("Reset Password")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 15)
            .alert(isPresented: $showSuccess) {
                Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
            }
            
            Button {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                setAppToLightMode()
                navigateToLogin = true
            } label :{
                Text("Log out")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 15)
            
            Button {
                deleteAccount()
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.red)
            .cornerRadius(10)
            .padding(.top, 15)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            fetchUserEmail()
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            email = user.email // Get the user's email
            let creationDate = user.metadata.creationDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            if let creationDate = creationDate {
                accountCreationDate = dateFormatter.string(from: creationDate)
            } else {
                accountCreationDate = "Unavailable"
            }
        } else {
            email = "No user found"
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found"
            showError = true
            return
        }
                
        user.delete { error in
            if let error = error {
                errorMessage = "Failed to delete account: \(error.localizedDescription)"
                showError = true
            } else {
                // Account deleted, log out and navigate to login screen
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                setAppToLightMode()
                navigateToLogin = true
            }
        }
    }
    
    private func resetPassword() {
        guard let email = email else {
            errorMessage = "No email associated with the account"
            showError = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                showError = true
            } else {
                successMessage = "The reset password link has been sent to your email"
                showSuccess = true
            }
        }
    }
    
    private func setAppToLightMode() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = .light  // Force light mode
        }
    }
    
    private func getInitial(from email: String) -> String {
        let firstInitial = email.prefix(1).uppercased()
        return firstInitial
    }
}

#Preview {
    ProfileView()
}
