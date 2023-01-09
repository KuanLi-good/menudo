//
//  PhotoPicker.swift
//  MenudoAdmin
//
//  Created by kuan on 31/10/22.
//

import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage
    
    func makeUIViewController(context: Context) -> some UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(photopicker: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let photopicker: PhotoPicker
        
        init(photopicker: PhotoPicker) {
            self.photopicker = photopicker
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                guard let data = image.jpegData(compressionQuality: 0.8),
                      let compressedImage = UIImage(data: data) else { return }
                photopicker.image = compressedImage
            }else {
                // return error showing an alert
            }
            picker.dismiss(animated: true)
        }
    }
}

