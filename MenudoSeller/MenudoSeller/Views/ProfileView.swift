//
//  ProfileView.swift
//  MenudoAdmin
//
//  Created by kuan on 30/10/22.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("email") var email: String = ""
    @AppStorage("full_name") var full_name: String = ""
    @AppStorage("userId") var userId: String = ""
    @AppStorage("restaurant_name") var restaurant_name: String = ""
    @State private var presentAlert = false
    @State private var inProgress = false
    @Environment(\.presentationMode) var presentationMode
    
    var disableForm: Bool {
        !self.textFieldValidatorEmail(self.email) || restaurant_name.isEmpty || email.isEmpty || full_name.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                if (inProgress) {
                    ProgressView("Updating...")
                    .progressViewStyle(.circular)
                }
            }
            Section {
                TextField("Restaurant Name", text: $restaurant_name)
                TextField("Owner", text: $full_name)
                TextField("Email", text: $email)
                
            }
            Section {
                Button("Log out") {
                    Serverless.shared.logout() { [self] result in
                        switch result {
                        case .success(_) :
                            userId = ""
                            break
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                    print("Logged out")
                }
                .buttonStyle(.automatic)
                .tint(.red)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
           ToolbarItem(placement: .navigationBarTrailing) {
               Button("Save") {
                   inProgress = true
                   Serverless.shared.edit_profile(with: User(id: userId, full_name: full_name, email: email, restaurant_name: restaurant_name)){ [self] result in
                       switch result {
                       case .success(_) :
                           inProgress = false
                           presentAlert = true
                           break
                       case .failure(let error):
                           print(error.localizedDescription)
                           inProgress = false
                           break
                       }
                       
                   }
                   print("Saving Profile")
               }
               .alert(isPresented: $presentAlert) {
               Alert(
                   title: Text("Success"),
                   message: Text("Profile has been updated!"),
                   dismissButton: .default(Text("OK")) {
                       presentationMode.wrappedValue.dismiss()
                   }
                   )
               }
               .buttonStyle(.plain)
               .disabled(disableForm || inProgress)
           }
       }
    }
    
    // https://stackoverflow.com/questions/59988892/swiftui-email-validation
    func textFieldValidatorEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }

    
   
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
