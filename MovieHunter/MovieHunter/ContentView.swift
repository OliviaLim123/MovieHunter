//
//  ContentView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .movieclapper
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            ZStack {
                switch selectedTab {
                case .movieclapper:
                    MovieListView()
                case .menucard:
                    SearchMovieView()
                case .heart:
                    WatchListView()
                case .person:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
