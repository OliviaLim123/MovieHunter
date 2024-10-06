//
//  ProfileViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import FirebaseAuth
import SwiftUI

// MARK: PROFILE VIEW MODEL
class ProfileViewModel: ObservableObject {
    
    // APP STORAGE to store the display mode preference
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    // METHOD to load the current logged user display mode preference
    func loadUserThemePreference() {
        if let userId = Auth.auth().currentUser?.uid {
            isDarkMode = UserDefaults.standard.bool(forKey: "\(userId)_isDarkMode")
        }
    }
    
    // METHOD to update the color scheme
    func updateColorScheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        // Display the window scene if it is dark or light mode
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
        // Store the updated display mode for the specific user id
        if let userId = Auth.auth().currentUser?.uid {
            UserDefaults.standard.set(isDarkMode, forKey: "\(userId)_isDarkMode")
        }
    }
}
