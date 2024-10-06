//
//  CustomTabBar.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

// MARK: TAB ENUM
enum Tab: String, CaseIterable {
    
    // ENUM CASES of custom tab
    case movieclapper
    case menucard
    case heart
    case person
}

// MARK: CUSTOM TAB BAR
struct CustomTabBar: View {
    
    // BINDING PROPERTY for selected tab
    @Binding var selectedTab: Tab
    // PRIVATE PROPERTY for image with the extension .fill
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    // PRIVATE PROPERTY for each custom tab icon color
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
    
    // BODY VIEW
    var body: some View {
        VStack {
            HStack {
                // Iterate through all tab cases and display them
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    // if the tab is selected, it will utilise the fillImage and tabColour with scale effect
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundStyle(selectedTab == tab ? tabColor : Color("customBlack"))
                        .font(.system(size:22))
                        .onTapGesture {
                            // Implement the ease in animation with 0.1 duration
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

// MARK: PREVIEW CUSTOM TAB BAR
#Preview {
    CustomTabBar(selectedTab: .constant(.movieclapper))
}
