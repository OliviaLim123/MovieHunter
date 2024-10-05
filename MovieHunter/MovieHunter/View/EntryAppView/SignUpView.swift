//
//  SignUpView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 5/10/2024.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State var color = Color.black.opacity(0.7)
    @State var email: String = ""
    @State var password: String = ""
    @State var repassword: String = ""
    @State var visible: Bool = false
    @State var revisible: Bool = false
    @State var alert: Bool = false
    @State var error: String = ""
    @State var navigateToLogin: Bool = false
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                GeometryReader {_ in
                    VStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .padding(.top, 40)
                        Text("Create an account")
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
                        
                        HStack(spacing: 15) {
                            if self.revisible {
                                TextField("Confirm Password", text: self.$repassword)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Confirm Password", text: self.$repassword)
                                    .autocapitalization(.none)
                            }
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
                        .navigationDestination(isPresented: $navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        }
                        
                    }
                    .padding(.horizontal, 25)
                }
            }
            
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    func register() {
        if self.email != "" {
            if self.password == self.repassword {
                Auth.auth().createUser(withEmail: self.email, password: self.password) { (res, err) in
                    if err != nil {
                        self.error = err!.localizedDescription
                        self.alert.toggle()
                        return
                    }
                    self.navigateToLogin = true
                    print("success")
                    UserDefaults.standard.set(true, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                }
            } else {
                self.error = "Password mismatch"
                self.alert.toggle()
            }
        } else {
            self.error = "Please fill all the credentials properly"
            self.alert.toggle()
        }
    }
}


#Preview {
    SignUpView()
}
