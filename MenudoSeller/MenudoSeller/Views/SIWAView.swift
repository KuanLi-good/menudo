//
//  SIWAView.swift
//  MenudoAdmin
//
//  Created by kuan on 31/10/22.
//

import SwiftUI
import AuthenticationServices

struct SIWAView: View {
    
    @AppStorage("email") var email: String = ""
    @AppStorage("full_name") var full_name: String = ""
    @AppStorage("userId") var userId: String = ""
    @AppStorage("uuid_major") var uuid_major: Int = -1
    @AppStorage("restaurant_name") var restaurant_name: String = ""
    @State private var inProgress = false
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        NavigationView {
            VStack {
                SignInWithAppleButton(.signIn) {
                    request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                switch result {
                case .success(let auth):
                    inProgress = true
                    switch auth.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
                        let id = credential.user
                        let email = credential.email ?? nil
                        let full_name = (credential.fullName?.familyName != nil) ? "\(credential.fullName?.givenName ?? "")  \(credential.fullName?.familyName ?? "")" : ""
                        let login = User(id: id, full_name: full_name, email: email)
                        register_if_not_exist(user: login)
                        break
                    default:
                        break
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    inProgress = false
                }
                
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white :.black)
            .frame(height: 50)
            .padding()
            .cornerRadius(8)
                
                if (inProgress) {
                    ProgressView("Signin...")
                    .progressViewStyle(.circular)
                }
        }
        .navigationTitle("Sign In")
        .navigationViewStyle(.stack)
    }
    }
    func register_if_not_exist(user: User){
//        createSpinnerView()
        Serverless.shared.register_if_not_exist(with: user) { [self] result in
            switch result {
            case .success(_) :
                Serverless.shared.me() { [self] result in
                    switch result {
                    case .success(let user) :
                        self.userId = user.id
                        self.email = user.email ?? ""
                        self.full_name = user.full_name ?? ""
                        self.uuid_major = user.uuid_major
                        self.restaurant_name = user.restaurant_name ?? ""
                        inProgress = false
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        inProgress = false
                        break
                    }}
            case .failure(let error):
                print(error.localizedDescription)
                inProgress = false
                break
            }
            }
        }
                                                                
}

struct SIWAView_Previews: PreviewProvider {
    static var previews: some View {
        SIWAView()
    }
}
