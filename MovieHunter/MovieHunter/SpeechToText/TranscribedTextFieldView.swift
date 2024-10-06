//
//  TranscribedTextFieldView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI

// MARK: TRANSCRIBED TEXT FIELD VIEW
public struct TranscribedTextFieldView: View {
    
    // STATE PROPERTIES of TranscribedTextFieldView
    @State var color:Color
    @State var isRecording:Bool
    
    // BINDING PROPERTY
    @Binding var searchText:String
    
    // PROPERTIES
    var placeHolder:String
    var micIconWidth:CGFloat
    var micIconHeight:CGFloat
    
    // INIT FUNCTION to initialise the text field
    public init(color: Color = Color("customBlack"), isRecording: Bool = false, searchText: Binding<String>, placeHolder: String = "Please enter movie title", micIconWidth: CGFloat = 12, micIconHeight: CGFloat = 20) {
        self.color = color
        self.isRecording = isRecording
        self._searchText = searchText
        self.placeHolder = placeHolder
        self.micIconWidth = micIconWidth
        self.micIconHeight = micIconHeight
    }
    
    // BODY VIEW
    public var body: some View {
        HStack {
            // Display the text field
            TextField("", text: $searchText,prompt: Text(placeHolder))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            // Display the microphone icon
            Image(systemName: "mic.fill")
                .resizable()
                .frame(width: micIconWidth, height: micIconHeight)
                .foregroundStyle( color )
            // If the microphone is clicked, it will start to record the voice
                .onTapGesture {
                    if !isRecording {
                        isRecording = true
                    }
                }
        }
        // Display the bottom sheet view (recording view)
        .sheet(isPresented: $isRecording) {
            SwiftUIView(isRecording: self.$isRecording, searchText: self.$searchText, color: self.$color)
                .presentationDetents([.medium, .fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
}
