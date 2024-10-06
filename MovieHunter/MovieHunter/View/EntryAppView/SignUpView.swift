//
//  SignUpView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: SIGN UP VIEW
struct SignUpView: View {
    
    // STATE PROPERTIES of SignUpView
    @State var color = Color.black.opacity(0.7)
    @State var email: String = ""
    @State var password: String = ""
    @State var repassword: String = ""
    @State var visible: Bool = false
    @State var revisible: Bool = false
    @State var alert: Bool = false
    @State var error: String = ""
    @State var navigateToLogin: Bool = false
    
    // BODY VIEW
    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                GeometryReader {_ in
                    VStack {
                        // Display application logo
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .padding(.top, 40)
                        
                        // Display the create account text
                        Text("Create an account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(self.color)
                            .padding(.top, 35)
                        
                        // Display email text field
                        TextField("Email", text: self.$email)
                            .autocapitalization(.none)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke( self.email != "" ? Color.blue : self.color, lineWidth: 2))
                            .padding(.top, 25)
                        
                        // Display password text filed
                        HStack(spacing: 15) {
                            // If it is visible, display the normal text field
                            if self.visible {
                                TextField("Password", text: self.$password)
                                    .autocapitalization(.none)
                            } else {
                                // If it is invisible, display the secure text field
                                SecureField("Password", text: self.$password)
                                    .autocapitalization(.none)
                            }
                            
                            // Button to see or hide the password
                            Button {
                                self.visible.toggle()
                            } label: {
                                Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(self.color)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke( self.password != "" ? Color.blue : self.color, lineWidth: 2))
                        .padding(.top, 25)
                        
                        // Display the confirm password text field
                        HStack(spacing: 15) {
                            // If it is visible, display the normal text field
                            if self.revisible {
                                TextField("Confirm Password", text: self.$repassword)
                                    .autocapitalization(.none)
                            } else {
                                // If it is invisible, display the secure text field
                                SecureField("Confirm Password", text: self.$repassword)
                                    .autocapitalization(.none)
                            }
                            
                            // Button to see or hide the confirm password
                            Button {
                                self.revisible.toggle()
                            } label: {
                                Image(systemName: self.revisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(self.color)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke( self.password != "" ? Color.blue : self.color, lineWidth: 2))
                        .padding(.top, 25)
                        
                        // Button to register the new user
                        Button {
                            self.register()
                        } label :{
                            Text("Register")
                                .foregroundStyle(.white)
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width - 50)
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                        // This button will navigate to the LoginView
                        .navigationDestination(isPresented: $navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            
            // ERROR HANDLING to display the error message
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    // FUNCTION to register the new user email and password
    func register() {
        if self.email != "" {
            if self.password == self.repassword {
                // Create user function from Firebase Auth
                Auth.auth().createUser(withEmail: self.email, password: self.password) { (res, err) in
                    // ERROR HANDLING
                    if err != nil {
                        self.error = err!.localizedDescription
                        self.alert.toggle()
                        return
                    }
                    self.navigateToLogin = true
                    // DEBUG
                    print("success")
                    // Save the status after successfully register
                    UserDefaults.standard.set(true, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                }
            } else {
                // ERROR HANDLING if the password mismatch
                self.error = "Password mismatch"
                self.alert.toggle()
            }
        } else {
            // ERROR HANDLING
            self.error = "Please fill all the credentials properly"
            self.alert.toggle()
        }
    }
}

// MARK: SIGN UP PREVIEW 
#Preview {
    SignUpView()
}
