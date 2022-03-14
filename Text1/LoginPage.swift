//
//  ContentView.swift
//  Text1
//
//  Created by GB-Kandy on 08/03/2022.
//

import SwiftUI
import Firebase				




struct LoginPage: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                
                VStack (spacing: 16) {
                    
                    Picker(selection: $isLoginMode, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                        Text ("Login").tag(true)
                        Text ("Create").tag(false)
                    }).pickerStyle(SegmentedPickerStyle()).padding()
               
                    if !isLoginMode {
                        
                        Button(action: {} ,
                               
                            label: {
                        Image(systemName:"person.fill").font(
                            .system(size:64)).padding()

                        })
                        
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        SecureField("Password", text: $password)
                    }.padding(12).background(Color.white)
                    
                    Button (action: handleAction,
                            label: {
                                HStack{
                                    Spacer()
                                    Text(isLoginMode ? "Login" : "Create Account")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .font(.system(size: 14, weight:.semibold))
                                    Spacer()
                                }.background(Color.blue)
                    }
                            
                    )
                    Text(self.LoginStatusMessage).foregroundColor(.red)
                }
                    
                }.padding()
                
            .navigationTitle( isLoginMode ? "Log in ":"Create Account")
        .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    private func handleAction() {
        if isLoginMode {
            LoginUser()
        }
        else{
            createNewAccount()
        }
    }
    
    private func LoginUser(){
        
        Auth.auth().signIn(withEmail: email, password: password){
                Result,Error in
                if Error != nil{
                    print("Falled to login user", Error as Any)
                    self.LoginStatusMessage = "Falled to login user\(String(describing: Error))"
                    return
            }
                print("Sucessfully login user: \(Result?.user.uid ?? "")")
            self.LoginStatusMessage = ("Sucessfully login user: \(Result?.user.uid ?? "")")}
        
    }
    
    @State var LoginStatusMessage = ""
    
    private func createNewAccount() {
        
    Auth.auth().createUser(withEmail: email, password: password){
            Result,Error in
            if Error != nil{
                print("Falled to create user", Error as Any)
                self.LoginStatusMessage = "Falled to create user\(String(describing: Error))"
                return
        }
            print("Sucessfully created user: \(Result?.user.uid ?? "")")
        self.LoginStatusMessage = ("Sucessfully created user: \(Result?.user.uid ?? "")")}
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
