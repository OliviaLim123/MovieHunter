//
//  ErrorView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import SwiftUI

// MARK: ERROR VIEW
struct ErrorView: View {
    
    // STATE PROPERTY for colour
    @State var color = Color.black.opacity(0.7)
    // BINDING PROPERTIES of ErrorView
    @Binding var alert : Bool
    @Binding var error : String
    
    // BODY VIEW
    var body: some View {
        ZStack {
            // Background colour
            Color.black.opacity(0.35)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    // Display the error message header
                    Text(self.error == "RESET" ? "Message" : "Error")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(self.color)
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                // Display the error message
                Text(self.error == "RESET" ? "Password reset link has been sent successfully to your email" : self.error)
                    .foregroundStyle(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                // Button for the alert with OK or Cancel option
                Button {
                    self.alert.toggle()
                } label: {
                    Text(self.error == "RESET" ? "OK": "Cancel")
                        .foregroundStyle(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius:10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}
