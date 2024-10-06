//
//  LoginView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: LOGIN VIEW
struct LoginView: View {
    
    // STATE PROPERTIES of LoginView
    @State var color = Color("customBlack")
    @State var email: String = ""
    @State var password: String = ""
    @State var visible: Bool = false
    @State var navigateToSignUp: Bool = false
    @State var navigateToHome: Bool = false
    @State var alert: Bool = false
    @State var error: String = ""
    
    // BODY VIEW
    var body: some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
                GeometryReader {_ in
                    VStack {
                        // Display the application logo
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .padding(.top, 85)
                        
                        // Display the log in text
                        Text("Log in to your account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(self.color)
                            .padding(.top, 35)
                        
                        // Display the email text field
                        TextField("Email", text: self.$email)
                            .autocapitalization(.none)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke( self.email != "" ? Color.blue : self.color, lineWidth: 2))
                            .padding(.top, 25)
                        
                        // Display the password text field
                        HStack(spacing: 15) {
                            if self.visible {
                                // If it is visible, display the normal text field
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
                        
                        HStack {
                            Spacer()
                            // Button to reset the password
                            Button {
                                self.reset()
                            } label: {
                                Text("Forget password")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.blue)
                            }
                            .padding(.top, 20)
                        }
                        
                        // Button to log in and it will verify the user credentials
                        Button {
                            self.verify()
                        } label :{
                            Text("Log in")
                                .foregroundStyle(.white)
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width - 50)
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                        // This button will navigate to the TabView
                        .navigationDestination(isPresented: $navigateToHome) {
                            TabView()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    .padding(.horizontal, 25)
                }
                
                // Button to register the new user
                Button {
                    self.navigateToSignUp = true
                } label: {
                    Text("Register")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                }
                .padding()
                // This button will navigate to the SignUpView
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUpView()
                }
            }
            
            // ERROR HANDLING by displaying the alert about the error
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    // FUNCTION to very the user email and password
    func verify() {
        if self.email != "" && self.password != "" {
            // Sign in function from the Firebase Auth
            Auth.auth().signIn(withEmail: self.email, password: self.password) { (res, err) in
                // ERROR HANDLING
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                self.navigateToHome = true
                // DEBUG
                print("success")
                // Save the user status after log in
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        } else {
            // ERROR HANDLING
            self.error = "Please fill all the contents properly"
            self.alert.toggle()
        }
    }
    
    // FUNCTION to reset the password
    func reset() {
        if self.email != "" {
            // Reset password function from Firebase Auth
            Auth.auth().sendPasswordReset(withEmail: self.email) { (err) in
                // ERROR HANDLING
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                self.error = "RESET"
                self.alert.toggle()
            }
        } else {
            // ERROR HANDLING
            self.error = "Email ID is empty"
            self.alert.toggle()
        }
    }
}

// MARK: LOGIN PREVIEW
#Preview {
    LoginView()
}
