//
//  ContentView.swift
//  Text1
//
//  Created by GB-Kandy on 08/03/2022.
//

import SwiftUI
import Firebase


class FirebaseManager :NSObject {
    
    let auth : Auth
    let storage : Storage
    
    static let shared = FirebaseManager()
    
    override init(){
        
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        
        self.storage = Storage.storage()
        
        super.init()
        
    }
    
}

struct LoginPage: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView{
                
                VStack (spacing: 16) {
                    
                    Picker(selection: $isLoginMode, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                        Text ("Login").tag(true)
                        Text ("Create").tag(false)
                    }).pickerStyle(SegmentedPickerStyle()).padding()
               
                    if !isLoginMode {
                        
                        Button(action: {
                            shouldShowImagePicker.toggle()
                        } ,
                               
                            label: {
                               
                            VStack{
                                    
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:128, height:128)
                                        .cornerRadius(64)
                                }else{
                                    Image(systemName:"person.fill").font(
                                        .system(size:64)).padding().foregroundColor(.black)
                                }
                                }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3))
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
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil, content: {
            ImagePicker(image: $image)
        })
       
    }
        @State var image :UIImage?
    
    private func handleAction() {
        if isLoginMode {
            LoginUser()
        }
        else{
            createNewAccount()
        }
    }
    
    private func LoginUser(){
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
                Result,Error in
                if Error != nil{
                    print("Falled to login user", Error as Any)
                    self.LoginStatusMessage = "Falled to login user\(String(describing: Error))"
                    return
            }
                print("Sucessfully login user: \(Result?.user.uid ?? "")")
            self.LoginStatusMessage = ("Sucessfully login user: \(Result?.user.uid ?? "")")}
            self.persitImageToStorage()
    }
    
    private func persitImageToStorage(){
      //  _ = UUID.init(uuidString: <#T##String#>)
        guard let uid =	FirebaseManager.shared.auth.currentUser?.uid
       
        else{return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
        else{return}
        ref.putData(imageData,metadata: nil) { metadata, Error in
            if let Error = Error {
                self.LoginStatusMessage = "failed to push image to Storage:\(Error)"
                return
            }
            ref.downloadURL { (URL, Error) in
                if let Error = Error{
                    self.LoginStatusMessage = "failed to retrieve downloadURL:\(Error)"
                    return
                }
                self.LoginStatusMessage = "Sucessfully storage image with url:\(URL?.absoluteString ?? "")"
                print(URL?.absoluteString)
            }
        }
    }
    
    @State var LoginStatusMessage = ""
    
    private func createNewAccount() {
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){
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
