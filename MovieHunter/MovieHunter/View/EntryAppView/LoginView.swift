//
//  LoginView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State var color = Color("customBlack")
    @State var email: String = ""
    @State var password: String = ""
    @State var visible: Bool = false
    @State private var navigateToSignUp: Bool = false
    @State private var navigateToHome: Bool = false
    @State var alert: Bool = false
    @State var error: String = ""
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
                GeometryReader {_ in
                    VStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .padding(.top, 85)
                        Text("Log in to your account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(self.color)
                            .padding(.top, 35)
                        TextField("Email", text: self.$email)
                            .autocapitalization(.none)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke( self.email != "" ? Color.blue : self.color, lineWidth: 2))
                            .padding(.top, 25)
                        HStack(spacing: 15) {
                            if self.visible {
                                TextField("Password", text: self.$password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: self.$password)
                                    .autocapitalization(.none)
                            }
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
                            Button {
                                self.reset()
                            } label: {
                                Text("Forget password")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.blue)
                            }
                            .padding(.top, 20)
                        }
                        
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
                        .navigationDestination(isPresented: $navigateToHome) {
                            TabView()
                                .navigationBarBackButtonHidden(true)
                        }
                        
                    }
                    .padding(.horizontal, 25)
                }
                Button {
                    self.navigateToSignUp = true
                } label: {
                    Text("Register")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                }
                .padding()
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUpView()
                }
            }
            
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    func verify() {
        if self.email != "" && self.password != "" {
            Auth.auth().signIn(withEmail: self.email, password: self.password) { (res, err) in
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                self.navigateToHome = true
                print("success")
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        } else {
            self.error = "Please fill all the contents properly"
            self.alert.toggle()
        }
    }
    
    func reset() {
        if self.email != "" {
            Auth.auth().sendPasswordReset(withEmail: self.email) { (err) in
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                self.error = "RESET"
                self.alert.toggle()
            }
        } else {
            self.error = "Email ID is empty"
            self.alert.toggle()
        }
    }
}

#Preview {
    LoginView()
}
