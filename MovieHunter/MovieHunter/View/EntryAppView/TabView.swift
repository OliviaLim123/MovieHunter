//
//  ContentView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

// MARK: TAB VIEW
struct TabView: View {
    
    // STATE PRIVATE PROPERTY of TabView
    @State private var selectedTab: Tab = .movieclapper
    
    // INIT FUNCTION
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    // BODY VIEW
    var body: some View {
        ZStack {
            VStack {
                // Assign each case with the proper view
                switch selectedTab {
                case .movieclapper:
                    MovieHomeView()
                case .menucard:
                    SearchMovieView()
                case .heart:
                    FavoriteMovieView()
                case .person:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 100)
            
            // Display the Custom Tab Bar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: TAB PREVIEW
#Preview {
    TabView()
}
