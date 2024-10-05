//
//  TranscribedTextFieldView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI
public struct TranscribedTextFieldView: View {
    
    @State var color:Color
    @State var isRecording:Bool
    @Binding var searchText:String
    // default values
    var placeHolder:String
    var micIconWidth:CGFloat
    var micIconHeight:CGFloat
    
    public init(color: Color = Color("customBlack"), isRecording: Bool = false, searchText: Binding<String>, placeHolder: String = "Please enter movie title", micIconWidth: CGFloat = 12, micIconHeight: CGFloat = 20) {
        self.color = color
        self.isRecording = isRecording
        self._searchText = searchText
        self.placeHolder = placeHolder
        self.micIconWidth = micIconWidth
        self.micIconHeight = micIconHeight
    }
    
    public var body: some View{
        HStack{
            TextField("", text: $searchText,prompt: Text(placeHolder))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Image(systemName: "mic.fill")
                .resizable()
                .frame(width: micIconWidth, height: micIconHeight)
                .foregroundStyle( color )
                .onTapGesture {
//                    isRecording.toggle()
                    if !isRecording {
                                // Ensure any ongoing session is stopped before starting
                                isRecording = true
                            }
                }
        }
        .sheet(isPresented: $isRecording){
                SwiftUIView(isRecording: self.$isRecording, searchText: self.$searchText, color: self.$color)
                    .presentationDetents([.medium, .fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
    }
}
