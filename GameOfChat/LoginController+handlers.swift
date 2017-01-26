//
//  LoginController+handlers.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/19.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func handleRegister() {
        
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            (user: FIRUser?, error) in
            
            if let error = error {
                
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                
                return
            }
            //sucessfully authenticated user
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                    
                         let values = ["name": name, "email": email, "profileImageUrl": profileImageURL]
                        self.registerUserIntoDatabase(uid: uid, values: values)
                    }
                    
                    
                })
            }
            
            
        })
        
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: Any]) {
        
        let ref = FIRDatabase.database().reference()
        
        let usersReference = ref.child("users").child(uid)
        
        
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, fer) in
            if let err = err {
                print(err)
                return
            }
            
//            self.messagesViewController?.fetchUserAndSetupNavBarTitle(uid: uid)
            let user = User()
            user.setValuesForKeys(values)
            self.messagesViewController?.setupNavBar(with: user)
            
            self.dismiss(animated: true, completion: nil)
            print("Saved user successfully into Firebase db")
        })
        
    }
    
}
