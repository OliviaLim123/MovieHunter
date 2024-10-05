//
//  ProfileViewModel.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import FirebaseAuth
import SwiftUI

class ProfileViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false  // Store the theme preference
    
    func loadUserThemePreference() {
        if let userId = Auth.auth().currentUser?.uid {
            isDarkMode = UserDefaults.standard.bool(forKey: "\(userId)_isDarkMode")
        }
    }
    
   func updateColorScheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
        if let userId = Auth.auth().currentUser?.uid {
            UserDefaults.standard.set(isDarkMode, forKey: "\(userId)_isDarkMode")
        }
    }
}
