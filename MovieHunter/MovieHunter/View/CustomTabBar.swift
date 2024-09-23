//
//  CustomTabBar.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case movieclapper
    case menucard
    case heart
    case person
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    private var tabColor: Color {
        switch selectedTab {
        case .movieclapper:
            return .blue
        case .menucard:
            return .green
        case .heart:
            return .red
        case .person:
            return .orange
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundStyle(selectedTab == tab ? tabColor : .gray)
                        .font(.system(size:22))
                        .onTapGesture {
                            withAnimation(.easeIn(duration:0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(25)
            .padding()
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.movieclapper))
}
