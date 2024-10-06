//
//  ProfileView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: PROFILE VIEW
struct ProfileView: View {
    
    // STATE PRIVATE PROPERTIES
    @State private var navigateToLogin: Bool = false
    @State private var email: String? = nil
    @State private var accountCreationDate: String? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var successMessage: String = ""
    
    // STATE OBJECT for view model
    @StateObject private var profileVM = ProfileViewModel()
    
    // BODY VIEW
    var body: some View {
        VStack {
            if let userEmail = email, let creationDate = accountCreationDate {
                VStack {
                    // Display the welcome back message
                    Text("Welcome back!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 20)
                    
                    // Display the initial profile picture
                    Text(getInitial(from: userEmail))
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                        .clipShape(Circle())
                        .padding(.bottom, 20)
                    
                    // Display the user email
                    Text("\(userEmail)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    // Display the account creation date
                    Text("Account Created on \(creationDate)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
            } else {
                // ERROR HANDLING
                Text("Fetching user info...")
                    .font(.title)
            }
            
            Spacer()
            // Button to enable the dark and light display modes
            Toggle(isOn: profileVM.$isDarkMode) {
                HStack {
                    // Display the icons
                    Image(systemName: profileVM.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(profileVM.isDarkMode ? .gray : .yellow)
                                .font(.system(size: 24))
                    
                    // Display the enable night mode text
                    Text("Enable Night Mode")
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 25)
            // Calling the update color scheme function
            .onChange(of: profileVM.isDarkMode) { newValue, _ in
                profileVM.updateColorScheme()
            }
            Spacer()
            
            // Button to reset password
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
            // Displaying the alert to display the password reset link has been sent message
            .alert(isPresented: $showSuccess) {
                Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
            }
            
            // Button to sign out
            Button {
                try! Auth.auth().signOut()
                // Update the user status after sign out
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
            
            // Button to delete account
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
            // Display the alert before deleting the account permanently
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        // Once this view appears, it will fetch the user email
        .onAppear {
            fetchUserEmail()
        }
        // It will navigate back to the login view
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // PRIVATE FUNCTTION to fetch the user email from Firebase Auth
    private func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            email = user.email
            let creationDate = user.metadata.creationDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            // Format the creation date
            if let creationDate = creationDate {
                accountCreationDate = dateFormatter.string(from: creationDate)
            } else {
                // ERROR HANDLING if creation date is unavailable
                accountCreationDate = "Unavailable"
            }
        } else {
            // ERROR HANDLING if the user is not found
            email = "No user found"
        }
    }
    
    // PRIVATE FUNCTION to delete account
    private func deleteAccount() {
        // ERROR HANDLING to check the current logged in user
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found"
            showError = true
            return
        }
        
        user.delete { error in
            if let error = error {
                // ERROR HANDLING if delete account is failed
                errorMessage = "Failed to delete account: \(error.localizedDescription)"
                showError = true
            } else {
                // Updated the user status
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                setAppToLightMode()
                // Account deleted then log out and navigate to login screen
                navigateToLogin = true
            }
        }
    }
    
    // PRIVATE FUNCTION to reset password
    private func resetPassword() {
        // ERROR HANDLING if there is no email
        guard let email = email else {
            errorMessage = "No email associated with the account"
            showError = true
            return
        }
        
        // Reset password function from Firebase Auth
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            // ERROR HANDLING if it is failed to reset password
            if let error = error {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                showError = true
            } else {
                successMessage = "The reset password link has been sent to your email"
                showSuccess = true
            }
        }
    }
    
    // PRIVATE FUNCTION to set the application in light display mode (default)
    private func setAppToLightMode() {
        // ERROR HANDLING
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        for window in windowScene.windows {
            // Force light mode since it is default
            window.overrideUserInterfaceStyle = .light
        }
    }
    
    // PRIVATE FUNCTION to get the first initial from the user email
    private func getInitial(from email: String) -> String {
        let firstInitial = email.prefix(1).uppercased()
        return firstInitial
    }
}

// MARK: PROFILE PREVIEW
#Preview {
    ProfileView()
}
