//
//  AddItemView.swift
//  MenudoAdmin
//
//  Created by kuan on 30/10/22.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    @EnvironmentObject var productList: ProductList
    @State private var isShowingPhotoPicker = false
    @State private var image = UIImage(systemName: "photo")!
    @State private var name = ""
    @State private var price = ""
    @AppStorage("userId") var userId: String = ""
    @State private var presentAlert = false
    @State private var inProgress = false
    @Environment(\.presentationMode) var presentationMode
    var priceFormatted: Double {
            return (Double(price) ?? 0) / 100
        }
    @State private var username = ""
    var disableForm: Bool {
        name.isEmpty || price.isEmpty
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
                .background(.white)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)
                .onTapGesture {
                    isShowingPhotoPicker = true
                }
            Spacer()
        }
        Form {
            Section {
                if (inProgress) {
                    ProgressView("Uploading...")
                    .progressViewStyle(.circular)
                }
            }
            Section {
                TextField("Name", text: $name)
                ZStack(alignment: .leading) {
                                    TextField("", text: $price)
                                        .keyboardType(.numberPad).foregroundColor(.clear)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .disableAutocorrection(true)
                                        .accentColor(.clear)
                                    Text("\(priceFormatted, specifier: "%.2f")")
                                }
                
            }
            
        }
        .navigationTitle(Text("Add Item"))
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker(image: $image)
        }
        .toolbar {
           ToolbarItem(placement: .navigationBarTrailing) {
               Button("Upload item") {
                   inProgress = true
                   var item = Product(name: name, price: priceFormatted)
                   S3.shared.upload(with: image.jpegData(compressionQuality: 1)!, with: item.seller + item.id){ [self] result in
                   switch result {
                   case .success(let url) :
                       item.image = url
                       Serverless.shared.upload_item(with: item) { [self] result in
                           switch result {
                           case .success(_) :
                               inProgress = false
                               presentAlert = true
                               productList.add(product: item)
                               break
                           case .failure(let error):
                               print(error.localizedDescription)
                               inProgress = false
                               break
                           }
                       }
                       break
                   case .failure(let error):
                       print(error.localizedDescription)
                       inProgress = false
                       break
                   }
               }
               }
               .alert(isPresented: $presentAlert) {
               Alert(
                   title: Text("Success"),
                   message: Text("Item has been added!"),
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
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
